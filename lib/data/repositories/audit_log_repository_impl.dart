import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/audit_log.entity.dart';
import '../../domain/repositories/audit_log_repository.dart';
import '../dto/audit_log.dto.dart';
import '../models/audit_log_model.dart';

class AuditLogRepositoryImpl implements AuditLogRepository {
  final FirebaseFirestore _firestore;

  AuditLogRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _auditLogsCol => _firestore.collection('audit_logs');

  @override
  Future<Result<List<AuditLogEntity>>> getAuditLogs({int limit = 100}) async {
    try {
      final snapshot = await _auditLogsCol
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      final logs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AuditLogModel.fromDto(AuditLogDto.fromMap(data, doc.id)).toEntity();
      }).toList();
      return Success(logs);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<AuditLogEntity>> createAuditLog(AuditLogEntity log) async {
    try {
      final docRef = _auditLogsCol.doc();
      final finalLog = log.copyWith(id: docRef.id, timestamp: DateTime.now());
      final dto = AuditLogModel.fromEntity(finalLog);
      final data = dto.toMap();
      data['timestamp'] = FieldValue.serverTimestamp();
      await docRef.set(data);
      return Success(finalLog);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<AuditLogEntity>> watchAuditLogs({int limit = 100}) {
    return _auditLogsCol
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AuditLogModel.fromDto(AuditLogDto.fromMap(data, doc.id)).toEntity();
      }).toList();
    });
  }
}
