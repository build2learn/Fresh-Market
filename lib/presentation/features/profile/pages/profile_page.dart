import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';
import 'package:fresh_market/core/constants/route_constants.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myProfile),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 48,
            backgroundColor: context.colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 48,
              color: context.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? context.l10n.customer,
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (user?.isAdmin ?? false) ...[
            const SizedBox(height: 4),
            Chip(
              label: Text(context.l10n.admin),
              backgroundColor: context.colorScheme.primaryContainer,
            ),
          ],
          if (user != null) ...[
            const SizedBox(height: 16),
            Card(
              color: context.colorScheme.primaryContainer.withOpacity(0.15),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: context.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getTierColor(user.membershipLevel).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.stars,
                        size: 32,
                        color: _getTierColor(user.membershipLevel),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                context.isRtl ? 'فئة العضوية: ' : 'Membership Tier: ',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getTierColor(user.membershipLevel),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  user.membershipLevel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.isRtl
                                ? 'النقاط المتاحة: ${user.loyaltyPoints} نقطة'
                                : 'Loyalty Points: ${user.loyaltyPoints} pts',
                            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            context.isRtl
                                ? 'إجمالي النقاط المكتسبة: ${user.lifetimePoints}'
                                : 'Lifetime points: ${user.lifetimePoints}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(context.l10n.email),
                  subtitle: Text(user?.email ?? ''),
                ),
                if (user?.phoneNumber != null)
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: Text(context.l10n.profile),
                    subtitle: Text(user!.phoneNumber!),
                  ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(context.l10n.memberSince),
                  subtitle: Text(
                    user?.createdAt.toString().split(' ')[0] ?? '',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: Text(context.isRtl ? 'طلباتي' : 'My Orders'),
                  subtitle: Text(context.isRtl ? 'عرض وتتبع طلبات الشراء' : 'View and track your orders'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(RouteConstants.myOrders),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(context.isRtl ? 'عناوين التوصيل' : 'Delivery Addresses'),
                  subtitle: Text(context.isRtl ? 'إدارة عناوين الشحن الخاصة بك' : 'Manage your shipping addresses'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/addresses'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: Text(context.l10n.signOut),
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Silver': return Colors.grey.shade600;
      case 'Gold': return Colors.amber.shade800;
      case 'Platinum': return Colors.teal.shade700;
      case 'Bronze':
      default:
        return Colors.brown.shade600;
    }
  }
}
