import '../../repositories/category_repository.dart';
import '../../../core/utils/result.dart';

class DeleteCategoryUseCase {
  final CategoryRepository _repository;

  DeleteCategoryUseCase({required CategoryRepository repository})
      : _repository = repository;

  Future<Result<void>> call(String categoryId) {
    return _repository.deleteCategory(categoryId);
  }
}
