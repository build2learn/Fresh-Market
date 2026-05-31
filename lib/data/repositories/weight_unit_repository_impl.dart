import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/weight_unit.entity.dart';
import '../../domain/repositories/weight_unit_repository.dart';
import '../datasources/firebase/weight_unit_firebase_datasource.dart';
import '../datasources/local/weight_unit_local_datasource.dart';
import '../models/weight_unit_model.dart';

class WeightUnitRepositoryImpl implements WeightUnitRepository {
  final WeightUnitFirebaseDataSource _firebaseDataSource;
  final WeightUnitLocalDataSource _localDataSource;

  WeightUnitRepositoryImpl({
    required WeightUnitFirebaseDataSource firebaseDataSource,
    required WeightUnitLocalDataSource localDataSource,
  })  : _firebaseDataSource = firebaseDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Result<List<WeightUnitEntity>>> getWeightUnits() async {
    try {
      final dtos = await _firebaseDataSource.getWeightUnits();
      final entities = dtos
          .map((dto) => WeightUnitModel.fromDto(dto).toEntity())
          .toList();
      await _localDataSource.cacheAll(dtos);
      return Success(entities);
    } on AppException catch (e) {
      final cached = await _localDataSource.getAll();
      if (cached.isNotEmpty) {
        final entities = cached
            .map((dto) => WeightUnitModel.fromDto(dto).toEntity())
            .toList();
        return Success(entities);
      }
      return Failure(e);
    } catch (e) {
      final cached = await _localDataSource.getAll();
      if (cached.isNotEmpty) {
        final entities = cached
            .map((dto) => WeightUnitModel.fromDto(dto).toEntity())
            .toList();
        return Success(entities);
      }
      return Failure(FirestoreException(message: 'Failed to load weight units'));
    }
  }

  @override
  Future<Result<WeightUnitEntity>> createWeightUnit(WeightUnitEntity unit) async {
    try {
      final dto = WeightUnitModel.fromEntity(unit);
      final result = await _firebaseDataSource.createWeightUnit(dto);
      return Success(WeightUnitModel.fromDto(result).toEntity());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to create weight unit'));
    }
  }

  @override
  Future<Result<WeightUnitEntity>> updateWeightUnit(WeightUnitEntity unit) async {
    try {
      final dto = WeightUnitModel.fromEntity(unit);
      final result = await _firebaseDataSource.updateWeightUnit(dto);
      return Success(WeightUnitModel.fromDto(result).toEntity());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to update weight unit'));
    }
  }

  @override
  Future<Result<void>> deleteWeightUnit(String id) async {
    try {
      await _firebaseDataSource.deleteWeightUnit(id);
      return Success(null);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to delete weight unit'));
    }
  }
}
