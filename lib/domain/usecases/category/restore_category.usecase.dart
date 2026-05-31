import '../../repositories/category_repository.dart';
import '../../../core/utils/result.dart';

class RestoreCategoryUseCase {
  final CategoryRepository _repository;

  RestoreCategoryUseCase({required CategoryRepository repository})
      : _repository = repository;

  Future<Result<void>> call(String categoryId) {
    return _repository.restoreCategory(categoryId);
  }
}
