import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/usecases/product/create_product.usecase.dart';
import 'package:fresh_market/domain/usecases/product/update_product.usecase.dart';

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
      categoryId.isNotEmpty;

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
    );
  }
}

class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final CreateProductUseCase _createProduct;
  final UpdateProductUseCase _updateProduct;
  final String? _editId;

  ProductFormNotifier({
    required CreateProductUseCase createProduct,
    required UpdateProductUseCase updateProduct,
    String? editId,
    ProductFormState? initialState,
  })  : _createProduct = createProduct,
        _updateProduct = updateProduct,
        _editId = editId,
        super(initialState ?? const ProductFormState());

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
    );

    final Result result;
    if (_editId != null) {
      result = await _updateProduct(entity, imagePath: imagePath);
    } else {
      result = await _createProduct(entity, imagePath: imagePath);
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
