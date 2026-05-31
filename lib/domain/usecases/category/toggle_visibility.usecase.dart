import '../../repositories/category_repository.dart';
import '../../../core/utils/result.dart';

class ToggleVisibilityUseCase {
  final CategoryRepository _repository;

  ToggleVisibilityUseCase({required CategoryRepository repository})
      : _repository = repository;

  Future<Result<void>> call(String categoryId, bool isVisible) {
    return _repository.toggleVisibility(categoryId, isVisible);
  }
}
