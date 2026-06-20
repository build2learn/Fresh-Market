import '../../core/utils/result.dart';
import '../entities/coupon.entity.dart';

abstract interface class CouponRepository {
  Future<Result<List<CouponEntity>>> getCoupons();
  Stream<List<CouponEntity>> watchCoupons();
  Future<Result<CouponEntity>> getCouponByCode(String code);
  Future<Result<CouponEntity>> createCoupon(CouponEntity coupon);
  Future<Result<CouponEntity>> updateCoupon(CouponEntity coupon);
  Future<Result<void>> deleteCoupon(String couponId);
}
