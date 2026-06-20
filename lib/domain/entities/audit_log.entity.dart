import 'package:equatable/equatable.dart';

class AuditLogEntity extends Equatable {
  final String id;
  final String userId;
  final String userEmail;
  final String action; // e.g., 'Create Product', 'Update Settings'
  final String details; // Short summary of what was changed
  final DateTime timestamp;

  const AuditLogEntity({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.action,
    required this.details,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, userEmail, action, details, timestamp];

  AuditLogEntity copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? action,
    String? details,
    DateTime? timestamp,
  }) {
    return AuditLogEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      action: action ?? this.action,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
