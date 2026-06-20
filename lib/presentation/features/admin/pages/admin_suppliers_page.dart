import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/data/providers/supplier_repository_provider.dart';
import '../../suppliers/providers/supplier_providers.dart';

class AdminSuppliersPage extends ConsumerStatefulWidget {
  const AdminSuppliersPage({super.key});

  @override
  ConsumerState<AdminSuppliersPage> createState() => _AdminSuppliersPageState();
}

class _AdminSuppliersPageState extends ConsumerState<AdminSuppliersPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersListStreamProvider);
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'إدارة الموردين' : 'Supplier Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/suppliers/new'),
          ),
        ],
      ),
      body: suppliersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('$err')),
        data: (list) {
          final filteredList = list.where((supplier) {
            final query = _searchQuery.toLowerCase();
            return supplier.name.toLowerCase().contains(query) ||
                supplier.contactPerson.toLowerCase().contains(query) ||
                supplier.phone.contains(query) ||
                supplier.email.toLowerCase().contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: isAr ? 'البحث عن مورد...' : 'Search supplier...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(isAr ? 'لا يوجد موردين' : 'No suppliers found'),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => context.push('/admin/suppliers/new'),
                              icon: const Icon(Icons.add),
                              label: Text(isAr ? 'إضافة مورد' : 'Add Supplier'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final supplier = filteredList[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              onTap: () => context.push('/admin/suppliers/details/${supplier.id}'),
                              leading: CircleAvatar(
                                backgroundColor: context.colorScheme.primaryContainer,
                                child: Icon(Icons.business, color: context.colorScheme.onPrimaryContainer),
                              ),
                              title: Text(
                                supplier.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${isAr ? "الشخص المسؤول" : "Contact"}: ${supplier.contactPerson}',
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            supplier.phone,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            supplier.email,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              supplier.address,
                                              style: const TextStyle(fontSize: 13),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.orange.shade800),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${isAr ? "الرصيد المستحق" : "Balance"}: ',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${supplier.balance.toStringAsFixed(2)} ${isAr ? "ج.م" : "EGP"}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: supplier.balance > 0 ? Colors.red.shade800 : Colors.green.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => context.push('/admin/suppliers/edit/${supplier.id}'),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outlined, color: context.colorScheme.error),
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text(isAr ? 'حذف المورد؟' : 'Delete Supplier?'),
                                          content: Text(
                                            isAr
                                                ? 'هل أنت متأكد من رغبتك في حذف هذا المورد؟ سيؤدي ذلك أيضاً إلى إخفاء أي سجلات مرتبطة به.'
                                                : 'Are you sure you want to delete this supplier? This might affect associated records.',
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
                                        await ref.read(supplierRepositoryProvider).deleteSupplier(supplier.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
