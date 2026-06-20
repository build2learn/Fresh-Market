import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/usecases/offer/create_offer.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/update_offer.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/get_offers.usecase.dart';
import 'package:fresh_market/domain/repositories/notification_repository.dart';
import 'package:fresh_market/domain/entities/notification.entity.dart';
import 'package:fresh_market/core/enums/notification_type.dart';
import 'package:fresh_market/domain/repositories/audit_log_repository.dart';
import 'package:fresh_market/domain/entities/audit_log.entity.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';

class OfferFormState {
  final String titleAr;
  final String titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? imageUrl;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> selectedProductIds;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isEditMode;
  final String offerType;

  const OfferFormState({
    this.titleAr = '',
    this.titleEn = '',
    this.descriptionAr,
    this.descriptionEn,
    this.imageUrl,
    this.isActive = false,
    this.startDate,
    this.endDate,
    this.selectedProductIds = const [],
    this.isSubmitting = false,
    this.errorMessage,
    this.isEditMode = false,
    this.offerType = 'PercentageDiscount',
  });

  bool get isValid =>
      titleAr.trim().isNotEmpty &&
      titleEn.trim().isNotEmpty &&
      startDate != null &&
      endDate != null &&
      endDate!.isAfter(startDate!) &&
      offerType.isNotEmpty;

  OfferFormState copyWith({
    String? titleAr,
    String? titleEn,
    String? descriptionAr,
    String? descriptionEn,
    String? imageUrl,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? selectedProductIds,
    bool? isSubmitting,
    String? errorMessage,
    bool? isEditMode,
    String? offerType,
  }) {
    return OfferFormState(
      titleAr: titleAr ?? this.titleAr,
      titleEn: titleEn ?? this.titleEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedProductIds: selectedProductIds ?? this.selectedProductIds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
      offerType: offerType ?? this.offerType,
    );
  }

  factory OfferFormState.fromEntity(OfferEntity entity) {
    return OfferFormState(
      titleAr: entity.titleAr,
      titleEn: entity.titleEn,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      imageUrl: entity.imageUrl,
      isActive: entity.isActive,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isEditMode: true,
      offerType: entity.offerType,
    );
  }
}

class OfferFormNotifier extends StateNotifier<OfferFormState> {
  final CreateOfferUseCase _createOffer;
  final UpdateOfferUseCase _updateOffer;
  final GetOfferUseCase _getOffer;
  final GetOfferProductsUseCase _getOfferProducts;
  final NotificationRepository _notificationRepository;
  final AuditLogRepository _auditLogRepository;
  final UserEntity? _currentUser;
  final String? _editId;

  OfferFormNotifier({
    required CreateOfferUseCase createOffer,
    required UpdateOfferUseCase updateOffer,
    required GetOfferUseCase getOffer,
    required GetOfferProductsUseCase getOfferProducts,
    required NotificationRepository notificationRepository,
    required AuditLogRepository auditLogRepository,
    required UserEntity? currentUser,
    String? editId,
    OfferFormState? initialState,
  })  : _createOffer = createOffer,
        _updateOffer = updateOffer,
        _getOffer = getOffer,
        _getOfferProducts = getOfferProducts,
        _notificationRepository = notificationRepository,
        _auditLogRepository = auditLogRepository,
        _currentUser = currentUser,
        _editId = editId,
        super(initialState ?? const OfferFormState()) {
    if (_editId != null && initialState == null) {
      _loadFromRepository();
    }
  }

  void setTitleAr(String value) => state = state.copyWith(titleAr: value);
  void setTitleEn(String value) => state = state.copyWith(titleEn: value);
  void setDescriptionAr(String value) => state = state.copyWith(descriptionAr: value);
  void setDescriptionEn(String value) => state = state.copyWith(descriptionEn: value);
  void setImageUrl(String? value) => state = state.copyWith(imageUrl: value);
  void setActive(bool value) => state = state.copyWith(isActive: value);
  void setStartDate(DateTime value) => state = state.copyWith(startDate: value);
  void setEndDate(DateTime value) => state = state.copyWith(endDate: value);
  void setOfferType(String value) => state = state.copyWith(offerType: value);
  void toggleProductId(String productId) {
    final ids = List<String>.from(state.selectedProductIds);
    if (ids.contains(productId)) {
      ids.remove(productId);
    } else {
      ids.add(productId);
    }
    state = state.copyWith(selectedProductIds: ids);
  }

  Future<void> _loadFromRepository() async {
    state = state.copyWith(isSubmitting: true);
    final result = await _getOffer(_editId!);
    if (result is Success<OfferEntity>) {
      state = OfferFormState.fromEntity(result.data);

      // Load linked product IDs for edit mode
      final productsResult = await _getOfferProducts(_editId);
      if (productsResult is Success<List<ProductEntity>>) {
        final productIds = productsResult.data.map((p) => p.id).toList();
        state = state.copyWith(selectedProductIds: productIds);
      }
    } else if (result is Failure<OfferEntity>) {
      state = state.copyWith(
          isSubmitting: false,
          errorMessage: result.error.message,
      );
    }
  }

  Future<String?> submit({String? imagePath}) async {
    if (!state.isValid) return 'Please fill all required fields';

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final entity = OfferEntity(
      id: _editId ?? '',
      titleAr: state.titleAr.trim(),
      titleEn: state.titleEn.trim(),
      descriptionAr: state.descriptionAr?.trim(),
      descriptionEn: state.descriptionEn?.trim(),
      imageUrl: state.imageUrl,
      isActive: state.isActive,
      startDate: state.startDate ?? DateTime.now(),
      endDate: state.endDate ?? DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      offerType: state.offerType,
    );

    final Result result;
    if (_editId != null) {
      result = await _updateOffer(entity, state.selectedProductIds, imagePath: imagePath);
    } else {
      result = await _createOffer(entity, state.selectedProductIds, imagePath: imagePath);
      if (result is Success<OfferEntity>) {
        if (_currentUser != null) {
          await _auditLogRepository.createAuditLog(
            AuditLogEntity(
              id: '',
              userId: _currentUser!.id,
              userEmail: _currentUser!.email,
              action: 'Offer Created',
              details: 'Created offer: ${result.data.titleEn} (${result.data.offerType})',
              timestamp: DateTime.now(),
            ),
          );
        }
        try {
          final createdOffer = result.data;
          await _notificationRepository.createNotification(
            NotificationEntity(
              id: '',
              userId: 'all',
              title: 'New Offer!',
              body: 'Check out our new offer: ${createdOffer.titleEn}',
              type: NotificationType.offer,
              createdAt: DateTime.now(),
              data: {
                'titleAr': 'عرض جديد!',
                'titleEn': 'New Offer!',
                'bodyAr': 'تحقق من عرضنا الجديد: ${createdOffer.titleAr}',
                'bodyEn': 'Check out our new offer: ${createdOffer.titleEn}',
                'offerId': createdOffer.id,
              },
            ),
          );
        } catch (_) {}
      }
    }

    if (result is Success) {
      state = state.copyWith(isSubmitting: false);
      return null;
    } else if (result is Failure) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: result.error.message,
      );
      return result.error.message;
    }

    state = state.copyWith(isSubmitting: false);
    return null;
  }
}
