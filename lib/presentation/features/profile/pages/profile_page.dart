import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';

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
          const SizedBox(height: 32),
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
}
