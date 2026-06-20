import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/coupon.entity.dart';
import '../../domain/repositories/coupon_repository.dart';
import '../dto/coupon.dto.dart';
import '../models/coupon_model.dart';

class CouponRepositoryImpl implements CouponRepository {
  final FirebaseFirestore _firestore;

  CouponRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _couponsCol => _firestore.collection('coupons');

  @override
  Future<Result<List<CouponEntity>>> getCoupons() async {
    try {
      final snapshot = await _couponsCol.get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CouponModel.fromDto(CouponDto.fromMap(data, doc.id)).toEntity();
      }).toList();
      return Success(list);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<CouponEntity>> watchCoupons() {
    return _couponsCol.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CouponModel.fromDto(CouponDto.fromMap(data, doc.id)).toEntity();
      }).toList();
    });
  }

  @override
  Future<Result<CouponEntity>> getCouponByCode(String code) async {
    try {
      final snapshot = await _couponsCol
          .where('code', isEqualTo: code.trim().toUpperCase())
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        return Failure(FirestoreException(message: 'Coupon not found'));
      }
      final doc = snapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      final coupon = CouponModel.fromDto(CouponDto.fromMap(data, doc.id)).toEntity();
      return Success(coupon);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<CouponEntity>> createCoupon(CouponEntity coupon) async {
    try {
      final docRef = _couponsCol.doc();
      final finalCoupon = coupon.copyWith(id: docRef.id, code: coupon.code.trim().toUpperCase());
      final dto = CouponModel.fromEntity(finalCoupon);
      await docRef.set(dto.toMap());
      return Success(finalCoupon);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<CouponEntity>> updateCoupon(CouponEntity coupon) async {
    try {
      final dto = CouponModel.fromEntity(coupon);
      await _couponsCol.doc(coupon.id).set(dto.toMap());
      return Success(coupon);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteCoupon(String couponId) async {
    try {
      await _couponsCol.doc(couponId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
