import '../../core/utils/result.dart';
import '../entities/audit_log.entity.dart';

abstract interface class AuditLogRepository {
  Future<Result<List<AuditLogEntity>>> getAuditLogs({int limit = 100});
  Future<Result<AuditLogEntity>> createAuditLog(AuditLogEntity log);
  Stream<List<AuditLogEntity>> watchAuditLogs({int limit = 100});
}
