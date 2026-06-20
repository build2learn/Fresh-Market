import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/stock_history.entity.dart';
import '../../domain/repositories/stock_history_repository.dart';
import '../dto/stock_history.dto.dart';

class StockHistoryRepositoryImpl implements StockHistoryRepository {
  final FirebaseFirestore _firestore;

  StockHistoryRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _historyCol => _firestore.collection('stock_history');

  @override
  Future<Result<List<StockHistoryEntity>>> getStockHistory({String? productId}) async {
    try {
      Query query = _historyCol.orderBy('createdAt', descending: true);
      if (productId != null && productId.isNotEmpty) {
        query = query.where('productId', isEqualTo: productId);
      }
      final snapshot = await query.get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return StockHistoryDto.fromMap(data, doc.id).toEntity();
      }).toList();
      return Success(list);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<StockHistoryEntity>> watchStockHistory({String? productId}) {
    Query query = _historyCol.orderBy('createdAt', descending: true);
    if (productId != null && productId.isNotEmpty) {
      query = query.where('productId', isEqualTo: productId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return StockHistoryDto.fromMap(data, doc.id).toEntity();
      }).toList();
    });
  }

  @override
  Future<Result<void>> logStockMovement(StockHistoryEntity entry) async {
    try {
      final docRef = _historyCol.doc();
      final dto = StockHistoryDto.fromEntity(entry.copyWith(id: docRef.id));
      final data = dto.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
