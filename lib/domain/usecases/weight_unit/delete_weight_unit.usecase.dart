import '../../repositories/weight_unit_repository.dart';
import '../../../core/utils/result.dart';

class DeleteWeightUnitUseCase {
  final WeightUnitRepository _repository;

  DeleteWeightUnitUseCase({required WeightUnitRepository repository})
      : _repository = repository;

  Future<Result<void>> call(String weightUnitId) {
    return _repository.deleteWeightUnit(weightUnitId);
  }
}
