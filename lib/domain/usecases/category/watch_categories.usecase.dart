import 'dart:async';
import '../../entities/category.entity.dart';
import '../../repositories/category_repository.dart';

class WatchCategoriesUseCase {
  final CategoryRepository _repository;

  WatchCategoriesUseCase({required CategoryRepository repository})
      : _repository = repository;

  Stream<List<CategoryEntity>> call() {
    return _repository.watchCategories();
  }
}
