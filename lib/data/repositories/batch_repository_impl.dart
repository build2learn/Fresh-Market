import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/batch.entity.dart';
import '../../domain/repositories/batch_repository.dart';
import '../dto/batch.dto.dart';
import '../models/batch_model.dart';

class BatchRepositoryImpl implements BatchRepository {
  final FirebaseFirestore _firestore;

  BatchRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _batchesCol => _firestore.collection('batches');

  @override
  Future<Result<List<BatchEntity>>> getBatches() async {
    try {
      final snapshot = await _batchesCol.orderBy(FirestoreConstants.createdAt, descending: true).get();
      final batches = snapshot.docs.map((doc) {
        final dto = BatchDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return BatchModel.fromDto(dto).toEntity();
      }).toList();
      return Success(batches);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<BatchEntity>> watchBatches() {
    return _batchesCol
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final dto = BatchDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return BatchModel.fromDto(dto).toEntity();
      }).toList();
    });
  }

  @override
  Future<Result<BatchEntity>> createBatch(BatchEntity batch) async {
    try {
      final docRef = await _batchesCol.add(
        BatchModel.fromEntity(batch).toMap()
          ..[FirestoreConstants.createdAt] = FieldValue.serverTimestamp()
          ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp(),
      );
      final doc = await docRef.get();
      final dto = BatchDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      return Success(BatchModel.fromDto(dto).toEntity());
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<BatchEntity>> updateBatch(BatchEntity batch) async {
    try {
      await _batchesCol.doc(batch.id).update(
        BatchModel.fromEntity(batch).toMap()
          ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp(),
      );
      return Success(batch);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteBatch(String batchId) async {
    try {
      await _batchesCol.doc(batchId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
