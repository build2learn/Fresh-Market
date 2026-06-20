import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/audit_log_repository.dart';
import '../repositories/audit_log_repository_impl.dart';

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return AuditLogRepositoryImpl(firestore: firestore);
});
