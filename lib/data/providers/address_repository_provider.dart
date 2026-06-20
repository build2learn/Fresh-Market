import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/address_repository.dart';
import '../repositories/address_repository_impl.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return AddressRepositoryImpl(firestore: firestore);
});
