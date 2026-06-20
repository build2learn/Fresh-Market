import '../dto/audit_log.dto.dart';
import '../../domain/entities/audit_log.entity.dart';

class AuditLogModel extends AuditLogDto {
  const AuditLogModel({
    required super.id,
    required super.userId,
    required super.userEmail,
    required super.action,
    required super.details,
    required super.timestamp,
  });

  factory AuditLogModel.fromDto(AuditLogDto dto) {
    return AuditLogModel(
      id: dto.id,
      userId: dto.userId,
      userEmail: dto.userEmail,
      action: dto.action,
      details: dto.details,
      timestamp: dto.timestamp,
    );
  }

  factory AuditLogModel.fromEntity(AuditLogEntity entity) {
    return AuditLogModel(
      id: entity.id,
      userId: entity.userId,
      userEmail: entity.userEmail,
      action: entity.action,
      details: entity.details,
      timestamp: entity.timestamp,
    );
  }

  AuditLogEntity toEntity() {
    return AuditLogEntity(
      id: id,
      userId: userId,
      userEmail: userEmail,
      action: action,
      details: details,
      timestamp: timestamp,
    );
  }
}
