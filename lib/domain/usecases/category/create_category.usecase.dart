import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/domain/repositories/category_repository.dart';

class CreateCategoryUseCase {
  final CategoryRepository _repository;

  CreateCategoryUseCase({required CategoryRepository repository})
      : _repository = repository;

  Future<Result<CategoryEntity>> call(CategoryEntity category) {
    if (category.nameAr.trim().isEmpty) {
      return Future.value(Failure(
        ValidationException(message: 'Arabic name is required', code: 'validation'),
      ));
    }
    if (category.nameEn.trim().isEmpty) {
      return Future.value(Failure(
        ValidationException(message: 'English name is required', code: 'validation'),
      ));
    }
    return _repository.createCategory(category);
  }
}
