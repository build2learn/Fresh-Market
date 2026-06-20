import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/enums/request_state.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../domain/entities/product.entity.dart';
import '../../../../domain/entities/stock_history.entity.dart';
import '../../../../data/providers/product_repository_provider.dart';
import '../../../../data/providers/stock_history_providers.dart';
import '../../../../data/providers/audit_log_repository_provider.dart';
import '../../../../domain/entities/audit_log.entity.dart';
import '../../auth/providers/auth_providers.dart';
import '../../products/providers/product_list_provider.dart';
import '../../products/providers/product_providers.dart';
import '../../../../core/utils/result.dart';

final stockHistoryStreamProvider = StreamProvider.autoDispose<List<StockHistoryEntity>>((ref) {
  final repository = ref.watch(stockHistoryRepositoryProvider);
  return repository.watchStockHistory();
});

class AdminInventoryPage extends ConsumerStatefulWidget {
  const AdminInventoryPage({super.key});

  @override
  ConsumerState<AdminInventoryPage> createState() => _AdminInventoryPageState();
}

class _AdminInventoryPageState extends ConsumerState<AdminInventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListProvider.notifier).startRealtimeSync();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productListProvider);
    final historyAsync = ref.watch(stockHistoryStreamProvider);

    final isRtl = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRtl ? 'إدارة المخزون والعمليات' : 'Inventory Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.warehouse_outlined),
              text: isRtl ? 'حالة المخزون' : 'Stock Levels',
            ),
            Tab(
              icon: const Icon(Icons.history),
              text: isRtl ? 'سجل الحركة' : 'Stock History',
            ),
            Tab(
              icon: const Icon(Icons.warning_amber),
              text: isRtl ? 'تنبيهات النواقص' : 'Low / Out Stock',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStockLevelsTab(productState),
          _buildStockHistoryTab(historyAsync),
          _buildStockAlertsTab(productState),
        ],
      ),
    );
  }

  Widget _buildStockLevelsTab(ProductListState state) {
    final isRtl = context.isRtl;
    if (state.requestState == RequestState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.requestState == RequestState.failure) {
      return Center(child: Text(state.errorMessage ?? 'Error loading products'));
    }

    final filteredProducts = state.products.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.nameEn.toLowerCase().contains(q) || p.nameAr.contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: isRtl ? 'بحث باسم المنتج...' : 'Search by product name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Text(
                    isRtl ? 'لا توجد منتجات تطابق البحث' : 'No products match search query',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredProducts.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return _ProductInventoryCard(product: product);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStockHistoryTab(AsyncValue<List<StockHistoryEntity>> historyAsync) {
    final isRtl = context.isRtl;
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (logs) {
        if (logs.isEmpty) {
          return Center(
            child: Text(
              isRtl ? 'سجل حركة المخزون فارغ' : 'Stock history log is empty',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          itemCount: logs.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final log = logs[index];
            return _StockHistoryTile(log: log);
          },
        );
      },
    );
  }

  Widget _buildStockAlertsTab(ProductListState state) {
    final isRtl = context.isRtl;
    if (state.requestState == RequestState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final alertProducts = state.products.where((p) => p.availableStock <= p.reorderLevel).toList();

    if (alertProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              isRtl ? 'جميع المنتجات لديها مخزون كافٍ!' : 'All products have sufficient stock!',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: alertProducts.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final product = alertProducts[index];
        return _ProductInventoryCard(product: product, showCompact: true);
      },
    );
  }
}

class _ProductInventoryCard extends ConsumerWidget {
  final ProductEntity product;
  final bool showCompact;

  const _ProductInventoryCard({
    required this.product,
    this.showCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = context.isRtl;
    final name = isRtl ? product.nameAr : product.nameEn;

    final isOutOfStock = product.availableStock <= 0;
    final isLowStock = product.availableStock <= product.reorderLevel && !isOutOfStock;

    Color badgeColor = Colors.green;
    String badgeText = isRtl ? 'مخزون كافٍ' : 'In Stock';
    if (isOutOfStock) {
      badgeColor = Colors.red.shade700;
      badgeText = isRtl ? 'نفد المخزون' : 'Out of Stock';
    } else if (isLowStock) {
      badgeColor = Colors.orange.shade700;
      badgeText = isRtl ? 'مخزون منخفض' : 'Low Stock';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    border: Border.all(color: badgeColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStockInfoColumn(
                  context,
                  isRtl ? 'الفعلي' : 'Physical',
                  '${product.currentStock}',
                  Colors.blue.shade700,
                ),
                _buildStockInfoColumn(
                  context,
                  isRtl ? 'المحجوز' : 'Reserved',
                  '${product.reservedStock}',
                  Colors.purple.shade700,
                ),
                _buildStockInfoColumn(
                  context,
                  isRtl ? 'المتاح للبيع' : 'Available',
                  '${product.availableStock}',
                  badgeColor,
                  isBold: true,
                ),
                if (!showCompact) ...[
                  _buildStockInfoColumn(
                    context,
                    isRtl ? 'الحد الأدنى' : 'Min Safety',
                    '${product.minimumStock}',
                    Colors.grey.shade700,
                  ),
                  _buildStockInfoColumn(
                    context,
                    isRtl ? 'نقطة الطلب' : 'Reorder Pt',
                    '${product.reorderLevel}',
                    Colors.grey.shade700,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showAdjustStockDialog(context, ref),
                  icon: const Icon(Icons.edit_note, size: 18),
                  label: Text(isRtl ? 'تعديل المخزون' : 'Adjust Stock'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _showReceiveStockDialog(context, ref),
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: Text(isRtl ? 'توريد / استلام' : 'Receive Stock'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfoColumn(
    BuildContext context,
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  void _showAdjustStockDialog(BuildContext context, WidgetRef ref) {
    final isRtl = context.isRtl;
    final controller = TextEditingController(text: '${product.currentStock}');
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRtl ? 'تعديل المخزون الفعلي' : 'Adjust Physical Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRtl ? product.nameAr : product.nameEn,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isRtl 
                  ? 'المحجوز حالياً: ${product.reservedStock} وحدة. المخزون المتاح سيصبح: الفعلي الجديد - المحجوز.'
                  : 'Currently reserved: ${product.reservedStock} units. New available stock will be: New Physical - Reserved.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isRtl ? 'المخزون الفعلي الجديد' : 'New Physical Stock',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: isRtl ? 'السبب (اختياري)' : 'Reason (Optional)',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newQty = int.tryParse(controller.text.trim());
              if (newQty == null || newQty < 0) {
                return;
              }
              final reason = reasonController.text.trim();
              final repo = ref.read(productRepositoryProvider);
              final result = await repo.adjustStock(
                product.id,
                newQty,
                reasonEn: reason.isNotEmpty ? reason : 'Stock manually adjusted by admin',
                reasonAr: reason.isNotEmpty ? reason : 'تم تعديل المخزون يدوياً بواسطة المسؤول',
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (result is Success<void>) {
                  final currentUser = ref.read(currentUserProvider);
                  if (currentUser != null) {
                    final auditLogRepo = ref.read(auditLogRepositoryProvider);
                    await auditLogRepo.createAuditLog(
                      AuditLogEntity(
                        id: '',
                        userId: currentUser.id,
                        userEmail: currentUser.email,
                        action: 'Stock Updated',
                        details: 'Manually adjusted stock for ${product.nameEn} to $newQty units. Reason: ${reason.isNotEmpty ? reason : 'N/A'}',
                        timestamp: DateTime.now(),
                      ),
                    );
                  }
                  context.showSnackBar(
                    isRtl ? 'تم تعديل المخزون بنجاح' : 'Stock adjusted successfully!',
                  );
                } else {
                  context.showSnackBar(
                    isRtl ? 'فشل تعديل المخزون' : 'Failed to adjust stock',
                    isError: true,
                  );
                }
              }
            },
            child: Text(isRtl ? 'تطبيق' : 'Apply'),
          ),
        ],
      ),
    );
  }

  void _showReceiveStockDialog(BuildContext context, WidgetRef ref) {
    final isRtl = context.isRtl;
    final controller = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRtl ? 'استلام وتوريد مخزون جديد' : 'Receive New Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRtl ? product.nameAr : product.nameEn,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isRtl 
                  ? 'سيتم إضافة هذه الكمية للمخزون الفعلي والمخزون المتاح.'
                  : 'This quantity will be added to both physical and available stock.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isRtl ? 'الكمية المستلمة' : 'Received Quantity',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: isRtl ? 'رقم الفاتورة أو المورد (اختياري)' : 'Invoice or Supplier (Optional)',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final qtyToAdd = int.tryParse(controller.text.trim());
              if (qtyToAdd == null || qtyToAdd <= 0) {
                return;
              }
              final reason = reasonController.text.trim();
              final repo = ref.read(productRepositoryProvider);
              final result = await repo.receiveStock(
                product.id,
                qtyToAdd,
                reasonEn: reason.isNotEmpty ? 'Received stock: $reason' : 'Stock received by admin',
                reasonAr: reason.isNotEmpty ? 'استلام شحنة مخزون: $reason' : 'تم استلام وتوريد شحنة جديدة بواسطة المسؤول',
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (result is Success<void>) {
                  final currentUser = ref.read(currentUserProvider);
                  if (currentUser != null) {
                    final auditLogRepo = ref.read(auditLogRepositoryProvider);
                    await auditLogRepo.createAuditLog(
                      AuditLogEntity(
                        id: '',
                        userId: currentUser.id,
                        userEmail: currentUser.email,
                        action: 'Stock Updated',
                        details: 'Received $qtyToAdd units for ${product.nameEn}. Total physical stock becomes: ${product.currentStock + qtyToAdd}. Reason: ${reason.isNotEmpty ? reason : 'N/A'}',
                        timestamp: DateTime.now(),
                      ),
                    );
                  }
                  context.showSnackBar(
                    isRtl ? 'تم إضافة المخزون الجديد بنجاح' : 'New stock received successfully!',
                  );
                } else {
                  context.showSnackBar(
                    isRtl ? 'فشل تسجيل استلام المخزون' : 'Failed to receive stock',
                    isError: true,
                  );
                }
              }
            },
            child: Text(isRtl ? 'تسجيل الاستلام' : 'Receive Stock'),
          ),
        ],
      ),
    );
  }
}

class _StockHistoryTile extends StatelessWidget {
  final StockHistoryEntity log;

  const _StockHistoryTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final isRtl = context.isRtl;
    final prodName = isRtl ? log.productNameAr : log.productNameEn;
    final reason = isRtl ? log.reasonAr : log.reasonEn;
    final dateStr = DateFormat.yMMMd(isRtl ? 'ar' : 'en').add_jm().format(log.createdAt);

    IconData icon;
    Color iconColor;
    String typeLabel = '';

    switch (log.type) {
      case 'order_created':
        icon = Icons.shopping_basket_outlined;
        iconColor = Colors.orange.shade700;
        typeLabel = isRtl ? 'حجز لطلب' : 'Order Allocation';
        break;
      case 'order_cancelled':
        icon = Icons.cancel_outlined;
        iconColor = Colors.green;
        typeLabel = isRtl ? 'إرجاع لإلغاء' : 'Order Restoration';
        break;
      case 'fulfillment':
        icon = Icons.local_shipping_outlined;
        iconColor = Colors.purple;
        typeLabel = isRtl ? 'شحن وتسليم' : 'Order Fulfillment';
        break;
      case 'receipt':
        icon = Icons.add_circle_outline;
        iconColor = Colors.teal;
        typeLabel = isRtl ? 'توريد واستلام' : 'Stock Receipt';
        break;
      case 'adjustment':
        icon = Icons.edit_note;
        iconColor = Colors.blue;
        typeLabel = isRtl ? 'تسوية وتعديل' : 'Manual Adjustment';
        break;
      default:
        icon = Icons.swap_horiz;
        iconColor = Colors.grey;
        typeLabel = log.type;
    }

    final changeSign = log.quantityChanged > 0 ? '+' : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                prodName.isNotEmpty ? prodName : (isRtl ? 'منتج غير معروف' : 'Unknown Product'),
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$changeSign${log.quantityChanged}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: log.quantityChanged > 0 ? Colors.green.shade700 : (log.quantityChanged < 0 ? Colors.red.shade700 : Colors.grey),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  typeLabel,
                  style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${isRtl ? 'السابق' : 'Prev'}: ${log.previousStock} ➔ ${isRtl ? 'الجديد' : 'New'}: ${log.newStock}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                reason,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                Text(
                  '${isRtl ? 'بواسطة' : 'By'}: ${log.createdBy}',
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
