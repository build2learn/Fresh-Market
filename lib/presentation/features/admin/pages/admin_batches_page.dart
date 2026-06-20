import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../domain/entities/batch.entity.dart';
import '../../../../domain/entities/product.entity.dart';
import '../../../../data/providers/product_repository_provider.dart';
import '../../../../data/providers/batch_repository_provider.dart';
import '../../../../core/utils/result.dart';
import 'package:fresh_market/presentation/features/inventory/providers/batch_providers.dart';

final _allProductsFutureProvider = FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final res = await repo.getProducts(limit: 1000);
  if (res is Success<List<List<ProductEntity>>>) {
    // Wait, the return type might be Success<List<ProductEntity>>
  }
  if (res is Success<List<ProductEntity>>) {
    return res.data;
  }
  return [];
});

class AdminBatchesPage extends ConsumerStatefulWidget {
  const AdminBatchesPage({super.key});

  @override
  ConsumerState<AdminBatchesPage> createState() => _AdminBatchesPageState();
}

class _AdminBatchesPageState extends ConsumerState<AdminBatchesPage> {
  String _filterType = 'All'; // All, Expired, 7Days, 30Days
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(batchesListStreamProvider);
    final stats = ref.watch(expiryAlertStatsProvider);
    final productsAsync = ref.watch(_allProductsFutureProvider);
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'إدارة الدفعات وتواريخ الصلاحية' : 'Batch & Expiry Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(batchesListStreamProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(batchesListStreamProvider),
        child: batchesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('$err')),
          data: (batches) {
            // Apply search & status filter
            final filtered = batches.where((b) {
              final query = _searchQuery.toLowerCase();
              final matchesQuery = b.batchCode.toLowerCase().contains(query) ||
                  b.productId.toLowerCase().contains(query);

              if (!matchesQuery) return false;

              final now = DateTime.now();
              if (_filterType == 'Expired') {
                return b.expiryDate.isBefore(now) && b.currentQuantity > 0;
              } else if (_filterType == '7Days') {
                return b.expiryDate.isAfter(now) &&
                    b.expiryDate.isBefore(now.add(const Duration(days: 7))) &&
                    b.currentQuantity > 0;
              } else if (_filterType == '30Days') {
                return b.expiryDate.isAfter(now) &&
                    b.expiryDate.isBefore(now.add(const Duration(days: 30))) &&
                    b.currentQuantity > 0;
              }
              return true;
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Stats Dashboard Row
                _buildStatsGrid(context, stats, isAr),
                const SizedBox(height: 24),

                // Controls row: Search + Filter + Add Button
                _buildControlsRow(context, productsAsync, isAr),
                const SizedBox(height: 16),

                // Batches List
                if (filtered.isEmpty)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          isAr ? 'لا توجد دفعات مطابقة للمعايير' : 'No batches match the filters',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final batch = filtered[index];
                      return _buildBatchCard(context, batch, isAr);
                    },
                  ),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, ExpiryAlertStats? stats, bool isAr) {
    final expiredCount = stats?.expiredCount ?? 0;
    final expiring7Count = stats?.expiringIn7DaysCount ?? 0;
    final expiring30Count = stats?.expiringIn30DaysCount ?? 0;

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      return GridView.count(
        crossAxisCount: isMobile ? 3 : 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isMobile ? 1.0 : 1.8,
        children: [
          _buildStatCard(
            title: isAr ? 'منتهية الصلاحية' : 'Expired Products',
            value: '$expiredCount',
            icon: Icons.dangerous_outlined,
            color: Colors.red.shade800,
            isSelected: _filterType == 'Expired',
            onTap: () => setState(() => _filterType = _filterType == 'Expired' ? 'All' : 'Expired'),
          ),
          _buildStatCard(
            title: isAr ? 'تنتهي خلال ٧ أيام' : 'Expiring in 7 Days',
            value: '$expiring7Count',
            icon: Icons.warning_amber_outlined,
            color: Colors.orange.shade800,
            isSelected: _filterType == '7Days',
            onTap: () => setState(() => _filterType = _filterType == '7Days' ? 'All' : '7Days'),
          ),
          _buildStatCard(
            title: isAr ? 'تنتهي خلال ٣٠ يوماً' : 'Expiring in 30 Days',
            value: '$expiring30Count',
            icon: Icons.calendar_month_outlined,
            color: Colors.blue.shade800,
            isSelected: _filterType == '30Days',
            onTap: () => setState(() => _filterType = _filterType == '30Days' ? 'All' : '30Days'),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? color.withOpacity(0.08) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: color, size: 16),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlsRow(BuildContext context, AsyncValue<List<ProductEntity>> productsAsync, bool isAr) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: isAr ? 'البحث عن دفعة أو منتج...' : 'Search batch or product...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        productsAsync.when(
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
          data: (products) => FilledButton.icon(
            onPressed: () => _showAddBatchDialog(context, products, isAr),
            icon: const Icon(Icons.add),
            label: Text(isAr ? 'تسجيل يدوي' : 'Register Batch'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatchCard(BuildContext context, BatchEntity batch, bool isAr) {
    final now = DateTime.now();
    final expiryFormatted = DateFormat('yyyy-MM-dd').format(batch.expiryDate);
    final isExpired = batch.expiryDate.isBefore(now);
    final isExpiringSoon = !isExpired && batch.expiryDate.isBefore(now.add(const Duration(days: 7)));

    Color statusColor = Colors.green.shade800;
    String statusText = isAr ? 'سليم' : 'Healthy';
    if (isExpired) {
      statusColor = Colors.red.shade800;
      statusText = isAr ? 'منتهي الصلاحية' : 'Expired';
    } else if (isExpiringSoon) {
      statusColor = Colors.orange.shade800;
      statusText = isAr ? 'قريب الانتهاء' : 'Expiring Soon';
    }

    final totalQty = batch.initialQuantity;
    final remainingQty = batch.currentQuantity;
    final fraction = totalQty > 0 ? remainingQty / totalQty : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.batchCode,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${batch.id}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCol(isAr ? 'المنتج' : 'Product ID', batch.productId),
                _buildInfoCol(isAr ? 'تاريخ الصلاحية' : 'Expiry Date', expiryFormatted, valueColor: statusColor),
                _buildInfoCol(
                  isAr ? 'تكلفة الشراء' : 'Unit Cost',
                  '${batch.unitCost.toStringAsFixed(2)} ${isAr ? "ج.م" : "EGP"}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isAr ? 'المخزون المتبقي في الدفعة' : 'Remaining Batch Stock',
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$remainingQty / $totalQty ${isAr ? "وحدة" : "units"} (حجز: ${batch.reservedQuantity})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fraction,
                          color: remainingQty > 0 ? statusColor : Colors.grey,
                          backgroundColor: Colors.grey.shade200,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                  onPressed: () => _confirmDeleteBatch(batch.id, isAr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCol(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _showAddBatchDialog(BuildContext context, List<ProductEntity> products, bool isAr) {
    ProductEntity? selectedProduct;
    final codeController = TextEditingController();
    final qtyController = TextEditingController();
    final costController = TextEditingController();
    DateTime? mfgDate = DateTime.now().subtract(const Duration(days: 1));
    DateTime? expDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isAr ? 'تسجيل دفعة مخزون جديدة' : 'Register New Batch'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ProductEntity>(
                  decoration: InputDecoration(
                    labelText: isAr ? 'المنتج' : 'Product',
                    border: const OutlineInputBorder(),
                  ),
                  items: products
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(isAr ? p.nameAr : p.nameEn),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setDialogState(() {
                      selectedProduct = val;
                      costController.text = (val!.price * 0.75).toStringAsFixed(2);
                      codeController.text = 'B-${val.id.replaceAll('prod_', '')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(
                    labelText: isAr ? 'كود الدفعة / التشغيلة' : 'Batch Code',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isAr ? 'كمية الدفعة' : 'Batch Quantity',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: costController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: isAr ? 'سعر شراء الوحدة' : 'Unit Cost',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: mfgDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (selected != null) {
                            setDialogState(() => mfgDate = selected);
                          }
                        },
                        child: Text(
                          mfgDate == null
                              ? (isAr ? 'تاريخ الإنتاج' : 'Mfg Date')
                              : DateFormat('yyyy-MM-dd').format(mfgDate!),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: expDate ?? DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (selected != null) {
                            setDialogState(() => expDate = selected);
                          }
                        },
                        child: Text(
                          expDate == null
                              ? (isAr ? 'تاريخ الانتهاء' : 'Expiry Date')
                              : DateFormat('yyyy-MM-dd').format(expDate!),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            FilledButton(
              onPressed: selectedProduct == null ||
                      codeController.text.trim().isEmpty ||
                      int.tryParse(qtyController.text) == null ||
                      double.tryParse(costController.text) == null ||
                      mfgDate == null ||
                      expDate == null
                  ? null
                  : () async {
                      final qty = int.parse(qtyController.text);
                      final cost = double.parse(costController.text);
                      final batch = BatchEntity(
                        id: '',
                        productId: selectedProduct!.id,
                        batchCode: codeController.text.trim(),
                        initialQuantity: qty,
                        currentQuantity: qty,
                        availableQuantity: qty,
                        reservedQuantity: 0,
                        unitCost: cost,
                        manufactureDate: mfgDate!,
                        expiryDate: expDate!,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      final repo = ref.read(batchRepositoryProvider);
                      final res = await repo.createBatch(batch);
                      if (res is Success && context.mounted) {
                        Navigator.pop(ctx);
                        ref.invalidate(batchesListStreamProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isAr ? 'تم تسجيل الدفعة بنجاح' : 'Batch registered successfully')),
                        );
                      }
                    },
              child: Text(isAr ? 'تسجيل' : 'Register'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteBatch(String id, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'حذف دفعة المخزون؟' : 'Delete Batch?'),
        content: Text(
          isAr
              ? 'هل أنت متأكد من رغبتك في حذف هذه الدفعة من سجلات المخزون؟'
              : 'Are you sure you want to delete this batch from the records?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final repo = ref.read(batchRepositoryProvider);
              final res = await repo.deleteBatch(id);
              if (res is Success && context.mounted) {
                Navigator.pop(ctx);
                ref.invalidate(batchesListStreamProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isAr ? 'تم حذف الدفعة بنجاح' : 'Batch deleted successfully')),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade800),
            child: Text(isAr ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }
}
