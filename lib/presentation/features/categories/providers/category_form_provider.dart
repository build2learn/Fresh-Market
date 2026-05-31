import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/domain/usecases/category/create_category.usecase.dart';
import 'package:fresh_market/domain/usecases/category/update_category.usecase.dart';
import 'package:fresh_market/data/providers/category_repository_provider.dart';

class CategoryFormState {
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  final bool isVisible;
  final int sortOrder;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isEditMode;

  const CategoryFormState({
    this.nameAr = '',
    this.nameEn = '',
    this.imageUrl,
    this.isVisible = true,
    this.sortOrder = 0,
    this.isSubmitting = false,
    this.errorMessage,
    this.isEditMode = false,
  });

  bool get isValid =>
      nameAr.trim().isNotEmpty && nameEn.trim().isNotEmpty;

  CategoryFormState copyWith({
    String? nameAr,
    String? nameEn,
    String? imageUrl,
    bool? isVisible,
    int? sortOrder,
    bool? isSubmitting,
    String? errorMessage,
    bool? isEditMode,
  }) {
    return CategoryFormState(
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      imageUrl: imageUrl ?? this.imageUrl,
      isVisible: isVisible ?? this.isVisible,
      sortOrder: sortOrder ?? this.sortOrder,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  factory CategoryFormState.fromEntity(CategoryEntity entity) {
    return CategoryFormState(
      nameAr: entity.nameAr,
      nameEn: entity.nameEn,
      imageUrl: entity.imageUrl,
      isVisible: entity.isVisible,
      sortOrder: entity.sortOrder,
      isEditMode: true,
    );
  }
}

class CategoryFormNotifier extends StateNotifier<CategoryFormState> {
  final CreateCategoryUseCase _createCategory;
  final UpdateCategoryUseCase _updateCategory;
  final String? _editId;

  CategoryFormNotifier({
    required CreateCategoryUseCase createCategory,
    required UpdateCategoryUseCase updateCategory,
    String? editId,
    CategoryFormState? initialState,
  })  : _createCategory = createCategory,
        _updateCategory = updateCategory,
        _editId = editId,
        super(initialState ?? const CategoryFormState());

  void setNameAr(String value) => state = state.copyWith(nameAr: value);
  void setNameEn(String value) => state = state.copyWith(nameEn: value);
  void setImageUrl(String? value) => state = state.copyWith(imageUrl: value);
  void setVisibility(bool value) => state = state.copyWith(isVisible: value);

  Future<String?> submit() async {
    if (!state.isValid) return 'Please fill all required fields';

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final entity = CategoryEntity(
      id: _editId ?? '',
      nameAr: state.nameAr.trim(),
      nameEn: state.nameEn.trim(),
      imageUrl: state.imageUrl,
      isVisible: state.isVisible,
      sortOrder: state.sortOrder,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final Result result;
    if (_editId != null) {
      result = await _updateCategory(entity);
    } else {
      result = await _createCategory(entity);
    }

    if (result is Success) {
      state = state.copyWith(isSubmitting: false);
      return null;
    } else if (result is Failure) {
      final error = result.error;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.message,
      );
      return error.message;
    }

    state = state.copyWith(isSubmitting: false);
    return null;
  }
}

final categoryFormProvider = StateNotifierProvider.family.autoDispose<
    CategoryFormNotifier, CategoryFormState, String?>((ref, editId) {
  final repo = ref.watch(categoryRepositoryProvider);
  return CategoryFormNotifier(
    createCategory: CreateCategoryUseCase(repository: repo),
    updateCategory: UpdateCategoryUseCase(repository: repo),
    editId: editId,
  );
});
