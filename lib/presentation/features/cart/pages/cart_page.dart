import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';
import 'package:fresh_market/presentation/features/cart/providers/cart_provider.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';
import 'package:fresh_market/data/providers/order_repository_provider.dart';
import 'package:fresh_market/domain/entities/address.entity.dart';
import 'package:fresh_market/data/providers/address_repository_provider.dart';

import 'package:fresh_market/data/providers/coupon_repository_provider.dart';
import 'package:fresh_market/domain/entities/coupon.entity.dart';

final _cartAddressesProvider = StreamProvider.autoDispose<List<AddressEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(addressRepositoryProvider).watchAddresses(user.id);
});

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _isCheckingOut = false;
  AddressEntity? _selectedAddress;
  CouponEntity? _appliedCoupon;
  double _discountAmount = 0.0;
  bool _isValidatingCoupon = false;
  late final TextEditingController _couponController;
  bool _useLoyaltyPoints = false;

  @override
  void initState() {
    super.initState();
    _couponController = TextEditingController();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon(double subtotal) async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isValidatingCoupon = true;
    });

    final repo = ref.read(couponRepositoryProvider);
    final result = await repo.getCouponByCode(code);

    if (!mounted) return;

    setState(() {
      _isValidatingCoupon = false;
    });

    if (result is Success<CouponEntity>) {
      final coupon = result.data;

      if (!coupon.isActive) {
        context.showSnackBar(
          context.isRtl ? 'هذا الكوبون غير فعال حالياً.' : 'This coupon is currently inactive.',
          isError: true,
        );
        return;
      }

      if (coupon.expiryDate != null && coupon.expiryDate!.isBefore(DateTime.now())) {
        context.showSnackBar(
          context.isRtl ? 'لقد انتهت صلاحية هذا الكوبون.' : 'This coupon has expired.',
          isError: true,
        );
        return;
      }

      if (coupon.usageLimit != null && coupon.usedCount >= coupon.usageLimit!) {
        context.showSnackBar(
          context.isRtl ? 'لقد تجاوز هذا الكوبون حد الاستخدام المسموح به.' : 'This coupon has reached its usage limit.',
          isError: true,
        );
        return;
      }

      if (subtotal < coupon.minOrderAmount) {
        context.showSnackBar(
          context.isRtl
              ? 'الحد الأدنى لتطبيق هذه القسيمة هو ${context.formatPrice(coupon.minOrderAmount)}'
              : 'Min order to apply this coupon is ${context.formatPrice(coupon.minOrderAmount)}',
          isError: true,
        );
        return;
      }

      setState(() {
        _appliedCoupon = coupon;
        if (coupon.type == 'Percentage') {
          _discountAmount = subtotal * (coupon.discountValue / 100.0);
        } else {
          _discountAmount = coupon.discountValue;
        }
        _discountAmount = _discountAmount.clamp(0.0, subtotal);
      });
      context.showSnackBar(
        context.isRtl ? 'تم تطبيق قسيمة الخصم بنجاح!' : 'Coupon applied successfully!',
      );
    } else {
      context.showSnackBar(
        context.isRtl ? 'قسيمة خصم غير صالحة أو منتهية الصلاحية.' : 'Invalid or expired coupon.',
        isError: true,
      );
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _discountAmount = 0.0;
      _couponController.clear();
    });
  }

  Future<void> _handleCheckout(
    BuildContext context, 
    List<CartItemEntity> cartItems,
    AddressEntity? selectedAddress,
  ) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      context.showSnackBar(
        context.isRtl
            ? 'يرجى تسجيل الدخول أولاً لإتمام الشراء.'
            : 'Please sign in first to checkout.',
        isError: true,
      );
      context.push(RouteConstants.signIn);
      return;
    }

    if (selectedAddress == null) {
      context.showSnackBar(
        context.isRtl
            ? 'يرجى تحديد أو إضافة عنوان توصيل أولاً.'
            : 'Please select or add a delivery address first.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isCheckingOut = true;
    });

    final totalPrice = ref.read(cartProvider.notifier).totalPrice;
    final orderItems = cartItems.map((c) => OrderItemEntity(
      productId: c.product.id,
      productName: c.product.nameEn,
      quantity: c.quantity,
      unitPrice: c.product.price,
      totalPrice: c.product.price * c.quantity,
      productNameAr: c.product.nameAr,
      productNameEn: c.product.nameEn,
      price: c.product.price,
      imageUrl: c.product.imageUrl,
      weight: c.product.weight,
      weightUnitId: c.product.weightUnitId,
    )).toList();

    const deliveryFee = 15.0;
    final remainingBeforeLoyalty = totalPrice + deliveryFee - _discountAmount;
    
    int pointsToRedeem = 0;
    double loyaltyDiscount = 0.0;
    if (_useLoyaltyPoints) {
      final maxPoints = user.loyaltyPoints;
      final pointsNeeded = (remainingBeforeLoyalty * 10).ceil();
      pointsToRedeem = pointsNeeded.clamp(0, maxPoints);
      loyaltyDiscount = pointsToRedeem / 10.0;
    }

    final grandTotal = (totalPrice + deliveryFee - _discountAmount - loyaltyDiscount).clamp(0.0, 999999.0);
    final pointsEarned = (grandTotal / 10.0).floor();

    final order = OrderEntity(
      id: '',
      orderNumber: '', // will be generated by the repository
      customerId: user.id,
      customerName: selectedAddress.name,
      phone: selectedAddress.phone,
      address: '${selectedAddress.address}, ${selectedAddress.city}',
      subtotal: totalPrice,
      deliveryFee: deliveryFee,
      total: grandTotal,
      
      userId: user.id,
      userEmail: user.email,
      status: 'Pending',
      totalAmount: grandTotal,
      couponCode: _appliedCoupon?.code,
      discountAmount: _discountAmount,
      loyaltyPointsEarned: pointsEarned,
      loyaltyPointsRedeemed: pointsToRedeem,
      loyaltyDiscount: loyaltyDiscount,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: orderItems,
      shippingAddress: selectedAddress,
    );

    final repository = ref.read(orderRepositoryProvider);
    final result = await repository.createOrder(order);

    if (!mounted) return;

    setState(() {
      _isCheckingOut = false;
    });

    if (result is Success<OrderEntity>) {
      ref.read(cartProvider.notifier).clear();
      _removeCoupon();
      setState(() {
        _useLoyaltyPoints = false;
      });
      ref.read(authNotifierProvider.notifier).refreshUser();
      context.showSnackBar(context.l10n.cartSuccess);
      context.go(RouteConstants.home);
    } else if (result is Failure<OrderEntity>) {
      context.showSnackBar(result.error.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final totalAmount = ref.watch(cartProvider.notifier).totalPrice;
    final addressesAsync = ref.watch(_cartAddressesProvider);
    final addresses = addressesAsync.valueOrNull ?? [];
    final activeAddress = _selectedAddress ?? (addresses.isNotEmpty ? addresses.first : null);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.cartTitle),
      ),
      body: cartItems.isEmpty
          ? _buildEmptyState(context)
          : _buildCartContent(context, cartItems, totalAmount, addresses, activeAddress),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.cartEmpty,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              context.isRtl
                  ? 'تصفح منتجاتنا وأضف ما تحتاجه إلى عربة التسوق!'
                  : 'Browse our products and add what you need to the cart!',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go(RouteConstants.home),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(
                context.isRtl ? 'ابدأ التسوق' : 'Start Shopping',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    List<CartItemEntity> cartItems,
    double totalAmount,
    List<AddressEntity> addresses,
    AddressEntity? activeAddress,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildCartItemCard(context, item);
            },
          ),
        ),
        _buildCheckoutSummary(context, cartItems, totalAmount, addresses, activeAddress),
      ],
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItemEntity item) {
    final product = item.product;
    final name = context.isRtl ? product.nameAr : product.nameEn;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: context.colorScheme.surfaceContainerHighest,
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.inventory_2,
                          color: context.colorScheme.outline,
                        ),
                      )
                    : Icon(
                        Icons.inventory_2,
                        color: context.colorScheme.outline,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.weight != null && product.weightUnitId != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.weightFormat(
                        product.weight!,
                        product.weightUnitId!,
                      ),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    context.formatPrice(product.price),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => ref.read(cartProvider.notifier).removeFromCart(product),
                  icon: Icon(
                    Icons.delete_outline,
                    color: context.colorScheme.error,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => ref
                          .read(cartProvider.notifier)
                          .updateQuantity(product, item.quantity - 1),
                      icon: const Icon(Icons.remove),
                      iconSize: 16,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () => ref
                          .read(cartProvider.notifier)
                          .updateQuantity(product, item.quantity + 1),
                      icon: const Icon(Icons.add),
                      iconSize: 16,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSummary(
    BuildContext context,
    List<CartItemEntity> cartItems,
    double totalAmount,
    List<AddressEntity> addresses,
    AddressEntity? activeAddress,
  ) {
    const deliveryFee = 15.0; // Mock delivery fee
    final user = ref.watch(currentUserProvider);
    final maxPoints = user?.loyaltyPoints ?? 0;
    final remainingBeforeLoyalty = totalAmount + deliveryFee - _discountAmount;
    
    int pointsToRedeem = 0;
    double loyaltyDiscount = 0.0;
    if (_useLoyaltyPoints && maxPoints > 0) {
      final pointsNeeded = (remainingBeforeLoyalty * 10).ceil();
      pointsToRedeem = pointsNeeded.clamp(0, maxPoints);
      loyaltyDiscount = pointsToRedeem / 10.0;
    }

    final grandTotal = (totalAmount + deliveryFee - _discountAmount - loyaltyDiscount).clamp(0.0, 999999.0);
    final isAr = context.isRtl;

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAddressSelectorSection(context, addresses, activeAddress),
            const Divider(height: 16),
            _buildCouponSection(context, totalAmount),
            if (user != null && user.loyaltyPoints > 0) ...[
              const Divider(height: 16),
              _buildLoyaltySection(context, user.loyaltyPoints, pointsToRedeem, loyaltyDiscount),
            ],
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.isRtl ? 'المجموع الفرعي' : 'Subtotal',
                  style: context.textTheme.bodyLarge,
                ),
                Text(
                  context.formatPrice(totalAmount),
                  style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.isRtl ? 'رسوم التوصيل' : 'Delivery Fee',
                  style: context.textTheme.bodyLarge,
                ),
                Text(
                  context.formatPrice(deliveryFee),
                  style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (_discountAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'الخصم' : 'Discount',
                    style: TextStyle(color: context.colorScheme.primary),
                  ),
                  Text(
                    '- ${context.formatPrice(_discountAmount)}',
                    style: TextStyle(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            if (loyaltyDiscount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'خصم نقاط الولاء' : 'Loyalty Discount',
                    style: TextStyle(color: Colors.orange.shade800),
                  ),
                  Text(
                    '- ${context.formatPrice(loyaltyDiscount)}',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.cartTotal,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.formatPrice(grandTotal),
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isCheckingOut
                    ? null
                    : () => _handleCheckout(context, cartItems, activeAddress),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isCheckingOut
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            context.isRtl
                                ? Icons.arrow_back_rounded
                                : Icons.arrow_forward_rounded,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.checkout,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection(BuildContext context, double subtotal) {
    final isAr = context.isRtl;
    if (_appliedCoupon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: context.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_appliedCoupon!.code} (${isAr ? "تم التطبيق" : "Applied"})',
                style: TextStyle(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: _removeCoupon,
            child: Text(
              isAr ? 'إزالة' : 'Remove',
              style: TextStyle(color: context.colorScheme.error),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _couponController,
            decoration: InputDecoration(
              hintText: isAr ? 'أدخل رمز الكوبون' : 'Enter Coupon Code',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isValidatingCoupon ? null : () => _applyCoupon(subtotal),
          child: _isValidatingCoupon
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isAr ? 'تطبيق' : 'Apply'),
        ),
      ],
    );
  }

  Widget _buildLoyaltySection(
    BuildContext context,
    int totalPoints,
    int pointsToRedeem,
    double loyaltyDiscount,
  ) {
    final isAr = context.isRtl;
    return SwitchListTile(
      value: _useLoyaltyPoints,
      onChanged: (val) {
        setState(() {
          _useLoyaltyPoints = val;
        });
      },
      title: Text(
        isAr ? 'استخدام نقاط الولاء' : 'Redeem Loyalty Points',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        isAr
            ? 'النقاط المتاحة: $totalPoints (${context.formatPrice(totalPoints / 10.0)})\nسيتم استخدام $pointsToRedeem نقطة لخصم ${context.formatPrice(loyaltyDiscount)}'
            : 'Available points: $totalPoints (${context.formatPrice(totalPoints / 10.0)})\nWill use $pointsToRedeem points to save ${context.formatPrice(loyaltyDiscount)}',
        style: const TextStyle(fontSize: 12),
      ),
      secondary: Icon(
        Icons.stars,
        color: _useLoyaltyPoints ? Colors.orange.shade800 : context.colorScheme.onSurfaceVariant,
      ),
      activeColor: Colors.orange.shade800,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildAddressSelectorSection(
    BuildContext context,
    List<AddressEntity> addresses,
    AddressEntity? activeAddress,
  ) {
    final isAr = context.isRtl;

    if (addresses.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colorScheme.errorContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colorScheme.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: context.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'مطلوب عنوان توصيل' : 'Delivery Address Required',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.error,
                    ),
                  ),
                  Text(
                    isAr
                        ? 'يرجى إضافة عنوان توصيل لإتمام الطلب.'
                        : 'Please add an address to complete your order.',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push('/addresses/new'),
              icon: const Icon(Icons.add, size: 16),
              label: Text(isAr ? 'إضافة' : 'Add'),
              style: TextButton.styleFrom(
                foregroundColor: context.colorScheme.error,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAr ? 'عنوان التوصيل' : 'Delivery Address',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push('/addresses/new'),
              icon: const Icon(Icons.add, size: 16),
              label: Text(isAr ? 'جديد' : 'New'),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<AddressEntity>(
          value: activeAddress,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_on_outlined),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          hint: Text(isAr ? 'اختر عنوان التوصيل' : 'Select delivery address'),
          items: addresses.map((addr) {
            return DropdownMenuItem<AddressEntity>(
              value: addr,
              child: Text(
                '${addr.name} (${addr.city}, ${addr.address})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedAddress = val;
            });
          },
        ),
      ],
    );
  }
}
