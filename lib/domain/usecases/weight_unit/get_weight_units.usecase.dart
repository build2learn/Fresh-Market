import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/weight_unit.entity.dart';
import 'package:fresh_market/domain/repositories/weight_unit_repository.dart';

class GetWeightUnitsUseCase {
  final WeightUnitRepository _repository;

  GetWeightUnitsUseCase({required WeightUnitRepository repository})
      : _repository = repository;

  Future<Result<List<WeightUnitEntity>>> call() {
    return _repository.getWeightUnits();
  }
}
