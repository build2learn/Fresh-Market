import '../../entities/category.entity.dart';
import '../../repositories/category_repository.dart';
import '../../../core/utils/result.dart';

class GetCategoriesUseCase {
  final CategoryRepository _repository;

  GetCategoriesUseCase({required CategoryRepository repository})
      : _repository = repository;

  Future<Result<List<CategoryEntity>>> call() {
    return _repository.getCategories();
  }
}
