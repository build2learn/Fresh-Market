class AuditLogDto {
  final String id;
  final String userId;
  final String userEmail;
  final String action;
  final String details;
  final DateTime timestamp;

  const AuditLogDto({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.action,
    required this.details,
    required this.timestamp,
  });

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  factory AuditLogDto.fromMap(Map<String, dynamic> map, String documentId) {
    return AuditLogDto(
      id: documentId,
      userId: map['userId'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      action: map['action'] as String? ?? '',
      details: map['details'] as String? ?? '',
      timestamp: _toDateTime(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'action': action,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
