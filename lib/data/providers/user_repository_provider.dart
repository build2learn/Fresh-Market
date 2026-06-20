import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/user_repository.dart';
import '../repositories/user_repository_impl.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(firestore: ref.watch(firebaseFirestoreProvider));
});
