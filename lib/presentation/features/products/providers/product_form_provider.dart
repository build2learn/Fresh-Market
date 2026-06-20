import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/usecases/product/create_product.usecase.dart';
import 'package:fresh_market/domain/usecases/product/update_product.usecase.dart';
import 'package:fresh_market/domain/usecases/product/get_products.usecase.dart';
import 'package:fresh_market/domain/repositories/notification_repository.dart';
import 'package:fresh_market/domain/entities/notification.entity.dart';
import 'package:fresh_market/core/enums/notification_type.dart';
import 'package:fresh_market/domain/repositories/audit_log_repository.dart';
import 'package:fresh_market/domain/entities/audit_log.entity.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';

class ProductFormState {
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String price;
  final String weight;
  final String weightUnitId;
  final String? imageUrl;
  final String categoryId;
  final bool isFeatured;
  final bool isAvailable;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isEditMode;
  final String productType;
  final String status;
  final String stockQuantity;
  final String minStock;
  final String alertQuantity;

  const ProductFormState({
    this.nameAr = '',
    this.nameEn = '',
    this.descriptionAr,
    this.descriptionEn,
    this.price = '',
    this.weight = '',
    this.weightUnitId = '',
    this.imageUrl,
    this.categoryId = '',
    this.isFeatured = false,
    this.isAvailable = true,
    this.isSubmitting = false,
    this.errorMessage,
    this.isEditMode = false,
    this.productType = 'Fresh',
    this.status = 'Available',
    this.stockQuantity = '50',
    this.minStock = '5',
    this.alertQuantity = '10',
  });

  bool get isValid =>
      nameAr.trim().isNotEmpty &&
      nameEn.trim().isNotEmpty &&
      price.isNotEmpty &&
      double.tryParse(price) != null &&
      double.parse(price) > 0 &&
      weight.isNotEmpty &&
      double.tryParse(weight) != null &&
      double.parse(weight) > 0 &&
      weightUnitId.isNotEmpty &&
      categoryId.isNotEmpty &&
      productType.isNotEmpty &&
      status.isNotEmpty &&
      stockQuantity.isNotEmpty &&
      int.tryParse(stockQuantity) != null &&
      int.parse(stockQuantity) >= 0 &&
      minStock.isNotEmpty &&
      int.tryParse(minStock) != null &&
      int.parse(minStock) >= 0 &&
      alertQuantity.isNotEmpty &&
      int.tryParse(alertQuantity) != null &&
      int.parse(alertQuantity) >= 0;

  ProductFormState copyWith({
    String? nameAr,
    String? nameEn,
    String? descriptionAr,
    String? descriptionEn,
    String? price,
    String? weight,
    String? weightUnitId,
    String? imageUrl,
    String? categoryId,
    bool? isFeatured,
    bool? isAvailable,
    bool? isSubmitting,
    String? errorMessage,
    bool? isEditMode,
    String? productType,
    String? status,
    String? stockQuantity,
    String? minStock,
    String? alertQuantity,
  }) {
    return ProductFormState(
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      weightUnitId: weightUnitId ?? this.weightUnitId,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      isFeatured: isFeatured ?? this.isFeatured,
      isAvailable: isAvailable ?? this.isAvailable,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
      productType: productType ?? this.productType,
      status: status ?? this.status,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStock: minStock ?? this.minStock,
      alertQuantity: alertQuantity ?? this.alertQuantity,
    );
  }

  factory ProductFormState.fromEntity(ProductEntity entity) {
    return ProductFormState(
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      descriptionAr: entity.descriptionAr,
      descriptionEn: entity.descriptionEn,
      price: entity.price.toString(),
      weight: entity.weight.toString(),
      weightUnitId: entity.weightUnitId,
      imageUrl: entity.imageUrl,
      categoryId: entity.categoryId,
      isFeatured: entity.isFeatured,
      isAvailable: entity.isAvailable,
      isEditMode: true,
      productType: entity.productType,
      status: entity.status,
      stockQuantity: entity.stockQuantity.toString(),
      minStock: entity.minStock.toString(),
      alertQuantity: entity.alertQuantity.toString(),
    );
  }
}

class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final CreateProductUseCase _createProduct;
  final UpdateProductUseCase _updateProduct;
  final GetProductUseCase _getProduct;
  final NotificationRepository _notificationRepository;
  final AuditLogRepository _auditLogRepository;
  final UserEntity? _currentUser;
  final String? _editId;
  double? _originalPrice;

  ProductFormNotifier({
    required CreateProductUseCase createProduct,
    required UpdateProductUseCase updateProduct,
    required GetProductUseCase getProduct,
    required NotificationRepository notificationRepository,
    required AuditLogRepository auditLogRepository,
    required UserEntity? currentUser,
    String? editId,
    ProductFormState? initialState,
  })  : _createProduct = createProduct,
        _updateProduct = updateProduct,
        _getProduct = getProduct,
        _notificationRepository = notificationRepository,
        _auditLogRepository = auditLogRepository,
        _currentUser = currentUser,
        _editId = editId,
        super(initialState ?? const ProductFormState()) {
    if (_editId != null && initialState == null) {
      _loadFromRepository();
    }
  }

  void setNameAr(String value) => state = state.copyWith(nameAr: value);
  void setNameEn(String value) => state = state.copyWith(nameEn: value);
  void setDescriptionAr(String value) => state = state.copyWith(descriptionAr: value);
  void setDescriptionEn(String value) => state = state.copyWith(descriptionEn: value);
  void setPrice(String value) => state = state.copyWith(price: value);
  void setWeight(String value) => state = state.copyWith(weight: value);
  void setWeightUnitId(String value) => state = state.copyWith(weightUnitId: value);
  void setImageUrl(String? value) => state = state.copyWith(imageUrl: value);
  void setCategoryId(String value) => state = state.copyWith(categoryId: value);
  void setFeatured(bool value) => state = state.copyWith(isFeatured: value);
  void setAvailable(bool value) => state = state.copyWith(isAvailable: value);
  void setProductType(String value) => state = state.copyWith(productType: value);
  void setStatus(String value) => state = state.copyWith(status: value);
  void setStockQuantity(String value) => state = state.copyWith(stockQuantity: value);
  void setMinStock(String value) => state = state.copyWith(minStock: value);
  void setAlertQuantity(String value) => state = state.copyWith(alertQuantity: value);

  Future<void> _loadFromRepository() async {
    state = state.copyWith(isSubmitting: true);
    final result = await _getProduct(_editId!);
    if (result is Success<ProductEntity>) {
      _originalPrice = result.data.price;
      state = ProductFormState.fromEntity(result.data);
    } else if (result is Failure<ProductEntity>) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: result.error.message,
      );
    }
  }

  Future<String?> submit({String? imagePath}) async {
    if (!state.isValid) return 'Please fill all required fields';

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final entity = ProductEntity(
      id: _editId ?? '',
      nameAr: state.nameAr.trim(),
      nameEn: state.nameEn.trim(),
      descriptionAr: state.descriptionAr?.trim(),
      descriptionEn: state.descriptionEn?.trim(),
      price: double.parse(state.price),
      weight: double.parse(state.weight),
      weightUnitId: state.weightUnitId,
      imageUrl: state.imageUrl,
      categoryId: state.categoryId,
      isFeatured: state.isFeatured,
      isAvailable: state.isAvailable,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productType: state.productType,
      status: state.status,
      stockQuantity: int.parse(state.stockQuantity),
      minStock: int.parse(state.minStock),
      alertQuantity: int.parse(state.alertQuantity),
    );

    final Result result;
    if (_editId != null) {
      result = await _updateProduct(entity, imagePath: imagePath);
      if (result is Success) {
        // Audit log
        if (_currentUser != null) {
          await _auditLogRepository.createAuditLog(
            AuditLogEntity(
              id: '',
              userId: _currentUser!.id,
              userEmail: _currentUser!.email,
              action: 'Update Product',
              details: 'Updated product ${entity.nameEn} (Stock: ${entity.stockQuantity}, Price: ${entity.price})',
              timestamp: DateTime.now(),
            ),
          );
        }

        if (_originalPrice != null && _originalPrice != entity.price) {
          if (_currentUser != null) {
            await _auditLogRepository.createAuditLog(
              AuditLogEntity(
                id: '',
                userId: _currentUser!.id,
                userEmail: _currentUser!.email,
                action: 'Price Changed',
                details: 'Price of ${entity.nameEn} changed from $_originalPrice to ${entity.price}',
                timestamp: DateTime.now(),
              ),
            );
          }
          try {
            await _notificationRepository.createNotification(
              NotificationEntity(
                id: '',
                userId: 'all',
                title: 'Price Updated',
                body: 'Price of ${entity.nameEn} has changed to ${entity.price} EGP',
                type: NotificationType.product,
                createdAt: DateTime.now(),
                data: {
                  'titleAr': 'تغيير السعر',
                  'titleEn': 'Price Changed',
                  'bodyAr': 'تم تغيير سعر ${entity.nameAr} إلى ${entity.price} جنيه مصري',
                  'bodyEn': 'Price of ${entity.nameEn} has changed to ${entity.price} EGP',
                  'productId': entity.id,
                },
              ),
            );
          } catch (_) {}
        }
      }
    } else {
      result = await _createProduct(entity, imagePath: imagePath);
      if (result is Success<ProductEntity>) {
        final createdProduct = result.data;
        // Audit log
        if (_currentUser != null) {
          await _auditLogRepository.createAuditLog(
            AuditLogEntity(
              id: '',
              userId: _currentUser!.id,
              userEmail: _currentUser!.email,
              action: 'Create Product',
              details: 'Created product ${createdProduct.nameEn} (Stock: ${createdProduct.stockQuantity}, Price: ${createdProduct.price})',
              timestamp: DateTime.now(),
            ),
          );
        }

        try {
          await _notificationRepository.createNotification(
            NotificationEntity(
              id: '',
              userId: 'all',
              title: 'New Product Added',
              body: '${createdProduct.nameEn} is now available!',
              type: NotificationType.product,
              createdAt: DateTime.now(),
              data: {
                'titleAr': 'منتج جديد',
                'titleEn': 'New Product Added',
                'bodyAr': 'منتج جديد: ${createdProduct.nameAr} متوفر الآن في المتجر!',
                'bodyEn': 'New product: ${createdProduct.nameEn} is now available in the store!',
                'productId': createdProduct.id,
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
