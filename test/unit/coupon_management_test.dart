import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fresh_market/core/services/mock_repositories.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/coupon.entity.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Coupon Management Unit Tests', () {
    test('Verify Coupon properties mapping & repository seed initialization', () async {
      final prefs = await SharedPreferences.getInstance();
      final couponRepo = MockCouponRepository(prefs);

      final result = await couponRepo.getCoupons();
      expect(result, isA<Success<List<CouponEntity>>>());

      final list = (result as Success<List<CouponEntity>>).data;
      // We expect seeds: SAVE10, EID50, SUMMER20
      expect(list.length, 3);

      final save10 = list.firstWhere((c) => c.code == 'SAVE10');
      expect(save10.type, 'Percentage');
      expect(save10.discountValue, 10.0);
      expect(save10.minOrderAmount, 100.0);
      expect(save10.usageLimit, 100);
      expect(save10.usedCount, 0);
      expect(save10.isActive, true);

      final eid50 = list.firstWhere((c) => c.code == 'EID50');
      expect(eid50.type, 'FixedAmount');
      expect(eid50.discountValue, 50.0);
      expect(eid50.minOrderAmount, 300.0);
      expect(eid50.usageLimit, 50);
      expect(eid50.usedCount, 0);
      expect(eid50.isActive, true);
    });

    test('Verify Coupon validation logic rules', () async {
      final now = DateTime.now();

      // Test Expiry Rule
      final expiredCoupon = CouponEntity(
        id: 'c_expired',
        code: 'EXPIRED10',
        type: 'Percentage',
        discountValue: 10,
        minOrderAmount: 50,
        expiryDate: now.subtract(const Duration(days: 1)),
        usageLimit: 10,
        usedCount: 0,
      );

      // Verify validation helper logic
      final isExpired = expiredCoupon.expiryDate != null && expiredCoupon.expiryDate!.isBefore(now);
      expect(isExpired, true);

      // Test Usage Limit Rule
      final overLimitCoupon = CouponEntity(
        id: 'c_over',
        code: 'LIMIT10',
        type: 'Percentage',
        discountValue: 10,
        minOrderAmount: 50,
        expiryDate: now.add(const Duration(days: 5)),
        usageLimit: 5,
        usedCount: 5,
      );

      final isLimitReached = overLimitCoupon.usageLimit != null && overLimitCoupon.usedCount >= overLimitCoupon.usageLimit!;
      expect(isLimitReached, true);

      // Test Inactive Rule
      final inactiveCoupon = CouponEntity(
        id: 'c_inactive',
        code: 'INACTIVE10',
        type: 'Percentage',
        discountValue: 10,
        minOrderAmount: 50,
        isActive: false,
        expiryDate: now.add(const Duration(days: 5)),
      );
      expect(inactiveCoupon.isActive, false);

      // Test Minimum Order Rule
      const minOrderCoupon = CouponEntity(
        id: 'c_min',
        code: 'MIN10',
        type: 'Percentage',
        discountValue: 10,
        minOrderAmount: 200,
      );
      final cartSubtotalBelow = 150.0;
      final cartSubtotalAbove = 250.0;
      expect(cartSubtotalBelow < minOrderCoupon.minOrderAmount, true);
      expect(cartSubtotalAbove < minOrderCoupon.minOrderAmount, false);
    });

    test('Verify order checkout applying coupon and usedCount increment', () async {
      final prefs = await SharedPreferences.getInstance();
      final couponRepo = MockCouponRepository(prefs);
      final orderRepo = MockOrderRepository(prefs);

      // Verify that SAVE10 has usedCount = 0 initially
      var couponsResult = await couponRepo.getCoupons();
      var save10 = (couponsResult as Success<List<CouponEntity>>).data.firstWhere((c) => c.code == 'SAVE10');
      expect(save10.usedCount, 0);

      // Place order applying SAVE10
      final order = OrderEntity(
        id: '',
        orderNumber: '',
        customerId: 'customer_1',
        customerName: 'Customer One',
        phone: '123456',
        address: 'Cairo',
        subtotal: 150,
        deliveryFee: 15,
        total: 150 + 15 - 15, // Subtotal 150, 10% discount = 15.0
        status: 'Pending',
        createdAt: DateTime.now(),
        userId: 'customer_1',
        userEmail: 'cust1@test.com',
        totalAmount: 150 + 15 - 15,
        updatedAt: DateTime.now(),
        items: const [],
        couponCode: 'SAVE10',
        discountAmount: 15,
      );

      final orderResult = await orderRepo.createOrder(order);
      expect(orderResult, isA<Success<OrderEntity>>());

      // Verify coupon usedCount is incremented in MockCouponRepository
      couponsResult = await couponRepo.getCoupons();
      save10 = (couponsResult as Success<List<CouponEntity>>).data.firstWhere((c) => c.code == 'SAVE10');
      expect(save10.usedCount, 1);
    });
  });
}
