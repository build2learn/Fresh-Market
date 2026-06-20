import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/weight_unit.entity.dart';
import 'package:fresh_market/domain/repositories/weight_unit_repository.dart';

class CreateWeightUnitUseCase {
  final WeightUnitRepository _repository;

  CreateWeightUnitUseCase({required WeightUnitRepository repository})
      : _repository = repository;

  Future<Result<WeightUnitEntity>> call(WeightUnitEntity weightUnit) {
    if (weightUnit.nameAr.trim().isEmpty) {
      return Future.value(Failure(
        ValidationException(message: 'Arabic name is required', code: 'validation'),
      ));
    }
    if (weightUnit.nameEn.trim().isEmpty) {
      return Future.value(Failure(
        ValidationException(message: 'English name is required', code: 'validation'),
      ));
    }
    if (weightUnit.abbr.trim().isEmpty) {
      return Future.value(Failure(
        ValidationException(message: 'Abbreviation is required', code: 'validation'),
      ));
    }
    return _repository.createWeightUnit(weightUnit);
  }
}
