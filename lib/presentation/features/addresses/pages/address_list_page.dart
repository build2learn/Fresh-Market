import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/address.entity.dart';
import 'package:fresh_market/data/providers/address_repository_provider.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';

final _addressesStreamProvider = StreamProvider.autoDispose<List<AddressEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(addressRepositoryProvider).watchAddresses(user.id);
});

class AddressListPage extends ConsumerWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(_addressesStreamProvider);
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'العناوين المحفوظة' : 'Saved Addresses'),
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 64,
                      color: context.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAr ? 'لا يوجد عناوين مسجلة بعد' : 'No addresses saved yet',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAr
                          ? 'أضف عنوان توصيل ليسهل عليك إتمام الطلبات!'
                          : 'Add a delivery address to make checkout faster!',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.push('/addresses/new'),
                      icon: const Icon(Icons.add),
                      label: Text(isAr ? 'إضافة عنوان جديد' : 'Add New Address'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return _buildAddressCard(context, ref, address);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error: $err', style: TextStyle(color: context.colorScheme.error)),
        ),
      ),
      floatingActionButton: addressesAsync.valueOrNull?.isNotEmpty == true
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/addresses/new'),
              icon: const Icon(Icons.add),
              label: Text(isAr ? 'إضافة عنوان' : 'Add Address'),
            )
          : null,
    );
  }

  Widget _buildAddressCard(BuildContext context, WidgetRef ref, AddressEntity address) {
    final isAr = context.isRtl;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: context.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      address.name,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => context.push('/addresses/edit/${address.id}'),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: context.colorScheme.error),
                      onPressed: () => _confirmDelete(context, ref, address),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),
            _buildDetailRow(Icons.phone_outlined, address.phone),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.map_outlined, '${address.city}, ${address.address}'),
            if (address.notes != null && address.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.notes, address.notes!, isItalic: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {bool isItalic = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AddressEntity address) {
    final isAr = context.isRtl;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? 'حذف العنوان' : 'Delete Address'),
        content: Text(
          isAr
              ? 'هل أنت متأكد من رغبتك في حذف هذا العنوان؟'
              : 'Are you sure you want to delete this address?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ref.read(addressRepositoryProvider).deleteAddress(address.id);
              if (context.mounted) {
                if (result is Success<void>) {
                  context.showSnackBar(
                    isAr ? 'تم حذف العنوان بنجاح!' : 'Address deleted successfully!',
                  );
                } else if (result is Failure<void>) {
                  context.showSnackBar(result.error.message, isError: true);
                }
              }
            },
            child: Text(
              isAr ? 'حذف' : 'Delete',
              style: TextStyle(color: context.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
