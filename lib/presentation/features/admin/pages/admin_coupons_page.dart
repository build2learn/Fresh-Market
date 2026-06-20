import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/data/providers/coupon_repository_provider.dart';
import '../../coupons/providers/coupon_providers.dart';

class AdminCouponsPage extends ConsumerWidget {
  const AdminCouponsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(couponsListStreamProvider);
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'قسائم الخصم' : 'Coupons Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/coupons/new'),
          ),
        ],
      ),
      body: couponsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('$err')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isAr ? 'لا توجد قسائم خصم بعد' : 'No coupons found'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.push('/admin/coupons/new'),
                    icon: const Icon(Icons.add),
                    label: Text(isAr ? 'إضافة قسيمة' : 'Add Coupon'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final coupon = list[index];
              final typeStr = coupon.type == 'Percentage'
                  ? (isAr ? 'نسبة مئوية' : 'Percentage')
                  : (isAr ? 'مبلغ ثابت' : 'Fixed Amount');
              final valStr = coupon.type == 'Percentage'
                  ? '${coupon.discountValue}%'
                  : context.formatPrice(coupon.discountValue);

              return Card(
                child: ListTile(
                  title: Text(
                    coupon.code,
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$typeStr - $valStr'),
                      Text(
                        isAr
                          ? 'الحد الأدنى للطلب: ${context.formatPrice(coupon.minOrderAmount)}'
                          : 'Min order amount: ${context.formatPrice(coupon.minOrderAmount)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (coupon.expiryDate != null)
                        Text(
                          isAr
                              ? 'تنتهي في: ${coupon.expiryDate!.toLocal().toString().split(' ')[0]}'
                              : 'Expires: ${coupon.expiryDate!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: coupon.isActive,
                        onChanged: (val) async {
                          final updated = coupon.copyWith(isActive: val);
                          await ref.read(couponRepositoryProvider).updateCoupon(updated);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => context.push('/admin/coupons/edit/${coupon.id}'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outlined, color: context.colorScheme.error),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(isAr ? 'حذف القسيمة؟' : 'Delete Coupon?'),
                              content: Text(
                                isAr
                                    ? 'هل أنت متأكد من رغبتك في حذف هذه القسيمة؟'
                                    : 'Are you sure you want to delete this coupon?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(isAr ? 'إلغاء' : 'Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(isAr ? 'حذف' : 'Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref.read(couponRepositoryProvider).deleteCoupon(coupon.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
