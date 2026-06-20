import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/data/providers/purchase_order_repository_provider.dart';
import '../../purchase_orders/providers/purchase_order_providers.dart';
import '../../suppliers/providers/supplier_providers.dart';

class AdminPurchaseOrdersPage extends ConsumerStatefulWidget {
  const AdminPurchaseOrdersPage({super.key});

  @override
  ConsumerState<AdminPurchaseOrdersPage> createState() => _AdminPurchaseOrdersPageState();
}

class _AdminPurchaseOrdersPageState extends ConsumerState<AdminPurchaseOrdersPage> {
  String? _selectedSupplierId;
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final isAr = context.isRtl;

    // Fetch suppliers for the filter dropdown
    final suppliersAsync = ref.watch(suppliersListStreamProvider);

    // Watch POs with active filters
    final filters = {
      'supplierId': _selectedSupplierId,
      'status': _selectedStatus == 'All' ? null : _selectedStatus,
    };
    final posAsync = ref.watch(purchaseOrdersListStreamProvider(filters));

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'أوامر الشراء للموردين' : 'Purchase Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/admin/purchase-orders/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Status Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: isAr ? 'الحالة' : 'Status',
                          border: InputBorder.none,
                        ),
                        items: [
                          DropdownMenuItem(value: 'All', child: Text(isAr ? 'الكل' : 'All Statuses')),
                          DropdownMenuItem(value: 'Pending', child: Text(isAr ? 'معلق' : 'Pending')),
                          DropdownMenuItem(value: 'Ordered', child: Text(isAr ? 'مطلوب' : 'Ordered')),
                          DropdownMenuItem(value: 'Received', child: Text(isAr ? 'تم الاستلام' : 'Received')),
                          DropdownMenuItem(value: 'Cancelled', child: Text(isAr ? 'ملغي' : 'Cancelled')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedStatus = val;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Supplier Filter
                    Expanded(
                      child: suppliersAsync.when(
                        loading: () => const SizedBox(height: 20, child: LinearProgressIndicator()),
                        error: (_, __) => const SizedBox(),
                        data: (suppliers) => DropdownButtonFormField<String?>(
                          value: _selectedSupplierId,
                          decoration: InputDecoration(
                            labelText: isAr ? 'المورد' : 'Supplier',
                            border: InputBorder.none,
                          ),
                          items: [
                            DropdownMenuItem(value: null, child: Text(isAr ? 'جميع الموردين' : 'All Suppliers')),
                            ...suppliers.map(
                              (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedSupplierId = val;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // List of POs
          Expanded(
            child: posAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('$err')),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isAr ? 'لا توجد أوامر شراء' : 'No purchase orders found'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => context.push('/admin/purchase-orders/new'),
                          icon: const Icon(Icons.add),
                          label: Text(isAr ? 'إنشاء أمر شراء' : 'Create Purchase Order'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final po = list[index];
                    final dateStr = po.createdAt.toLocal().toString().split(' ')[0];
                    final totalQty = po.items.fold<int>(0, (sum, i) => sum + i.quantityOrdered);
                    
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () => context.push('/admin/purchase-orders/edit/${po.id}'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    po.id.startsWith('po_') ? '#${po.id.substring(3)}' : '#${po.id}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  _StatusChip(status: po.status, isAr: isAr),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.business, size: 20, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    po.supplierName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.shopping_basket_outlined, size: 18, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        isAr
                                            ? 'المنتجات المطلوبة: $totalQty وحدة'
                                            : 'Ordered Products: $totalQty units',
                                        style: TextStyle(color: context.colorScheme.onSurfaceVariant, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        dateStr,
                                        style: TextStyle(color: context.colorScheme.onSurfaceVariant, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool isAr;
  const _StatusChip({required this.status, required this.isAr});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case 'Pending':
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        text = isAr ? 'معلق' : 'Pending';
      case 'Ordered':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        text = isAr ? 'مطلوب' : 'Ordered';
      case 'Received':
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        text = isAr ? 'مستلم' : 'Received';
      case 'Cancelled':
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        text = isAr ? 'ملغي' : 'Cancelled';
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade900;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
