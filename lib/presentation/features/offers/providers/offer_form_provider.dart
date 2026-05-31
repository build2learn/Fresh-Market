import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';
import 'package:fresh_market/domain/usecases/offer/create_offer.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/update_offer.usecase.dart';

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
  });

  bool get isValid =>
      titleAr.trim().isNotEmpty &&
      titleEn.trim().isNotEmpty &&
      startDate != null &&
      endDate != null &&
      endDate!.isAfter(startDate!);

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
    );
  }
}

class OfferFormNotifier extends StateNotifier<OfferFormState> {
  final CreateOfferUseCase _createOffer;
  final UpdateOfferUseCase _updateOffer;
  final String? _editId;

  OfferFormNotifier({
    required CreateOfferUseCase createOffer,
    required UpdateOfferUseCase updateOffer,
    String? editId,
    OfferFormState? initialState,
  })  : _createOffer = createOffer,
        _updateOffer = updateOffer,
        _editId = editId,
        super(initialState ?? const OfferFormState());

  void setTitleAr(String value) => state = state.copyWith(titleAr: value);
  void setTitleEn(String value) => state = state.copyWith(titleEn: value);
  void setDescriptionAr(String value) => state = state.copyWith(descriptionAr: value);
  void setDescriptionEn(String value) => state = state.copyWith(descriptionEn: value);
  void setImageUrl(String? value) => state = state.copyWith(imageUrl: value);
  void setActive(bool value) => state = state.copyWith(isActive: value);
  void setStartDate(DateTime value) => state = state.copyWith(startDate: value);
  void setEndDate(DateTime value) => state = state.copyWith(endDate: value);
  void toggleProductId(String productId) {
    final ids = List<String>.from(state.selectedProductIds);
    if (ids.contains(productId)) {
      ids.remove(productId);
    } else {
      ids.add(productId);
    }
    state = state.copyWith(selectedProductIds: ids);
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
    );

    final Result result;
    if (_editId != null) {
      result = await _updateOffer(entity, state.selectedProductIds, imagePath: imagePath);
    } else {
      result = await _createOffer(entity, state.selectedProductIds, imagePath: imagePath);
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
