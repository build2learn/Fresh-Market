import 'dart:async';
import '../entities/weight_unit.entity.dart';
import '../../core/utils/result.dart';

abstract interface class WeightUnitRepository {
  Future<Result<List<WeightUnitEntity>>> getWeightUnits();
  Future<Result<WeightUnitEntity>> createWeightUnit(WeightUnitEntity unit);
  Future<Result<WeightUnitEntity>> updateWeightUnit(WeightUnitEntity unit);
  Future<Result<void>> deleteWeightUnit(String id);
}
