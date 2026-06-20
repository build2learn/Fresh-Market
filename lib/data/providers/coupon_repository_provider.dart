import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../repositories/coupon_repository_impl.dart';

final couponRepositoryProvider = Provider<CouponRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return CouponRepositoryImpl(firestore: firestore);
});
