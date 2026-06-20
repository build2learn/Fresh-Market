import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/batch_repository.dart';
import '../repositories/batch_repository_impl.dart';

final batchRepositoryProvider = Provider<BatchRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return BatchRepositoryImpl(firestore: firestore);
});
