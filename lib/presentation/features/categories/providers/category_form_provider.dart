import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/domain/usecases/category/create_category.usecase.dart';
import 'package:fresh_market/domain/usecases/category/update_category.usecase.dart';
import 'package:fresh_market/domain/usecases/category/get_categories.usecase.dart';
import 'package:fresh_market/data/providers/category_repository_provider.dart';
import 'category_providers.dart';

class CategoryFormState {
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  final String? imagePath;
  final bool isVisible;
  final bool isActive;
  final int sortOrder;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isEditMode;

  const CategoryFormState({
    this.nameAr = '',
    this.nameEn = '',
    this.imageUrl,
    this.imagePath,
    this.isVisible = true,
    this.isActive = true,
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
    String? imagePath,
    bool? isVisible,
    bool? isActive,
    int? sortOrder,
    bool? isSubmitting,
    String? errorMessage,
    bool? isEditMode,
  }) {
    return CategoryFormState(
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      isVisible: isVisible ?? this.isVisible,
      isActive: isActive ?? this.isActive,
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
      isActive: entity.isActive,
      sortOrder: entity.sortOrder,
      isEditMode: true,
    );
  }
}

class CategoryFormNotifier extends StateNotifier<CategoryFormState> {
  final CreateCategoryUseCase _createCategory;
  final UpdateCategoryUseCase _updateCategory;
  final GetCategoriesUseCase _getCategories;
  final String? _editId;

  CategoryFormNotifier({
    required CreateCategoryUseCase createCategory,
    required UpdateCategoryUseCase updateCategory,
    required GetCategoriesUseCase getCategories,
    String? editId,
    CategoryFormState? initialState,
  })  : _createCategory = createCategory,
        _updateCategory = updateCategory,
        _getCategories = getCategories,
        _editId = editId,
        super(initialState ?? const CategoryFormState()) {
    if (_editId != null && initialState == null) {
      _loadFromRepository();
    }
  }

  void setNameAr(String value) => state = state.copyWith(nameAr: value);
  void setNameEn(String value) => state = state.copyWith(nameEn: value);
  void setImageUrl(String? value) => state = state.copyWith(imageUrl: value);
  void setImagePath(String? value) => state = state.copyWith(imagePath: value);
  void setVisibility(bool value) => state = state.copyWith(isVisible: value);
  void setActive(bool value) => state = state.copyWith(isActive: value);

  Future<void> _loadFromRepository() async {
    state = state.copyWith(isSubmitting: true);
    final result = await _getCategories();
    if (result is Success<List<CategoryEntity>>) {
      final category = result.data.cast<CategoryEntity?>().firstWhere(
        (c) => c?.id == _editId,
        orElse: () => null,
      );
      if (category != null) {
        state = CategoryFormState.fromEntity(category);
      } else {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Category not found',
        );
      }
    } else if (result is Failure<List<CategoryEntity>>) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: result.error.message,
      );
    }
  }

  Future<String?> submit() async {
    if (!state.isValid) return 'Please fill all required fields';

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final entity = CategoryEntity(
      id: _editId ?? '',
      nameAr: state.nameAr.trim(),
      nameEn: state.nameEn.trim(),
      imageUrl: state.imageUrl,
      isVisible: state.isVisible,
      isActive: state.isActive,
      sortOrder: state.sortOrder,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final Result result;
    if (_editId != null) {
      result = await _updateCategory(entity, imagePath: state.imagePath);
    } else {
      result = await _createCategory(entity, imagePath: state.imagePath);
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
  
  CategoryFormState? initialState;
  if (editId != null) {
    final listState = ref.read(categoryListProvider);
    final category = listState.categories.cast<CategoryEntity?>().firstWhere(
      (c) => c?.id == editId,
      orElse: () => null,
    );
    if (category != null) {
      initialState = CategoryFormState.fromEntity(category);
    }
  }

  return CategoryFormNotifier(
    createCategory: CreateCategoryUseCase(repository: repo),
    updateCategory: UpdateCategoryUseCase(repository: repo),
    getCategories: GetCategoriesUseCase(repository: repo),
    editId: editId,
    initialState: initialState,
  );
});
