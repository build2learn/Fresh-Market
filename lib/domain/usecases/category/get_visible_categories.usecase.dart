import '../../entities/category.entity.dart';
import '../../repositories/category_repository.dart';
import '../../../core/utils/result.dart';

class GetVisibleCategoriesUseCase {
  final CategoryRepository _repository;

  GetVisibleCategoriesUseCase({required CategoryRepository repository})
      : _repository = repository;

  Future<Result<List<CategoryEntity>>> call() {
    return _repository.getVisibleCategories();
  }
}
