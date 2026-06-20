import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/notification_repository.dart';
import '../repositories/notification_repository_impl.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(firestore: ref.watch(firebaseFirestoreProvider));
});
