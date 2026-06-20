import 'dart:async';
import '../../core/utils/result.dart';
import '../entities/batch.entity.dart';

abstract interface class BatchRepository {
  Future<Result<List<BatchEntity>>> getBatches();
  Stream<List<BatchEntity>> watchBatches();
  Future<Result<BatchEntity>> createBatch(BatchEntity batch);
  Future<Result<BatchEntity>> updateBatch(BatchEntity batch);
  Future<Result<void>> deleteBatch(String batchId);
}
