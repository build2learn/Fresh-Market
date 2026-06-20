import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/lookup_repository.dart';
import '../repositories/lookup_repository_impl.dart';

final lookupRepositoryProvider = Provider<LookupRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return LookupRepositoryImpl(firestore: firestore);
});
