import '../../repositories/category_repository.dart';
import '../../../core/utils/result.dart';

class ReorderCategoriesUseCase {
  final CategoryRepository _repository;

  ReorderCategoriesUseCase({required CategoryRepository repository})
      : _repository = repository;

  Future<Result<void>> call(List<String> categoryIds) {
    return _repository.reorderCategories(categoryIds);
  }
}
