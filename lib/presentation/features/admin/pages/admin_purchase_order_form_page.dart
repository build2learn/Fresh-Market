import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/domain/entities/purchase_order.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/core/utils/result.dart';
import '../../purchase_orders/providers/purchase_order_providers.dart';
import '../../suppliers/providers/supplier_providers.dart';

final _allProductsProvider = FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final res = await repo.getProducts(limit: 1000);
  if (res is Success<List<ProductEntity>>) {
    return res.data;
  }
  return [];
});

class AdminPurchaseOrderFormPage extends ConsumerStatefulWidget {
  final String? editId;
  const AdminPurchaseOrderFormPage({super.key, this.editId});

  @override
  ConsumerState<AdminPurchaseOrderFormPage> createState() => _AdminPurchaseOrderFormPageState();
}

class _AdminPurchaseOrderFormPageState extends ConsumerState<AdminPurchaseOrderFormPage> {
  String? _selectedSupplierId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchaseOrderFormProvider(widget.editId));
    final notifier = ref.read(purchaseOrderFormProvider(widget.editId).notifier);
    final suppliersAsync = ref.watch(suppliersListStreamProvider);
    final productsAsync = ref.watch(_allProductsProvider);
    final isAr = context.isRtl;

    final totalAmount = state.items.fold<double>(0.0, (sum, item) {
      final qty = state.status == 'Received' ? item.quantityReceived : item.quantityOrdered;
      return sum + (qty * item.unitCost);
    });

    // Monitor supplier state updates
    ref.listen<PurchaseOrderFormState>(purchaseOrderFormProvider(widget.editId), (prev, next) {
      if (prev?.supplierId != next.supplierId && next.supplierId.isNotEmpty) {
        setState(() {
          _selectedSupplierId = next.supplierId;
        });
      }
    });

    final isReadOnly = state.status == 'Received' || state.status == 'Cancelled';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editId == null
              ? (isAr ? 'إنشاء أمر شراء جديد' : 'New Purchase Order')
              : (isAr ? 'تفاصيل أمر الشراء' : 'Purchase Order Details'),
        ),
        actions: [
          if (widget.editId != null && state.status == 'Ordered') ...[
            FilledButton.icon(
              onPressed: () => _showReceiveDialog(context, state, notifier, isAr),
              icon: const Icon(Icons.download),
              label: Text(isAr ? 'استلام الشحنة' : 'Receive Items'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: suppliersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('$err')),
        data: (suppliers) => productsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('$err')),
          data: (products) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(color: context.colorScheme.onErrorContainer),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Supplier Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'المعلومات الأساسية' : 'General Info',
                            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedSupplierId,
                            decoration: InputDecoration(
                              labelText: isAr ? 'المورد *' : 'Supplier *',
                              prefixIcon: const Icon(Icons.business),
                              border: const OutlineInputBorder(),
                            ),
                            disabledHint: Text(state.supplierName),
                            items: suppliers
                                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                                .toList(),
                            onChanged: isReadOnly || widget.editId != null
                                ? null
                                : (val) {
                                    if (val != null) {
                                      final supplier = suppliers.firstWhere((s) => s.id == val);
                                      notifier.setSupplier(supplier.id, supplier.name);
                                      setState(() {
                                        _selectedSupplierId = val;
                                      });
                                    }
                                  },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isAr ? 'الحالة الحالية:' : 'Current Status:'),
                              _StatusTag(status: state.status, isAr: isAr),
                            ],
                          ),
                          if (widget.editId != null && !isReadOnly) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (state.status == 'Pending') ...[
                                  OutlinedButton(
                                    onPressed: () async {
                                      notifier.setStatus('Ordered');
                                      await notifier.submit();
                                    },
                                    child: Text(isAr ? 'طلب التوريد (Ordered)' : 'Mark as Ordered'),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                OutlinedButton(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(isAr ? 'إلغاء أمر الشراء؟' : 'Cancel Purchase Order?'),
                                        content: Text(isAr
                                            ? 'هل تريد إلغاء هذا الأمر تماماً؟ لا يمكن التراجع عن هذا الإجراء.'
                                            : 'Are you sure you want to cancel this order? This action is irreversible.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: Text(isAr ? 'رجوع' : 'No'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: Text(isAr ? 'نعم، إلغاء' : 'Yes, Cancel'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      notifier.setStatus('Cancelled');
                                      await notifier.submit();
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: context.colorScheme.error,
                                    side: BorderSide(color: context.colorScheme.error),
                                  ),
                                  child: Text(isAr ? 'إلغاء الأمر' : 'Cancel Order'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Items Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isAr ? 'المنتجات المطلوبة' : 'Ordered Products',
                                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (!isReadOnly)
                                TextButton.icon(
                                  onPressed: () => _showAddProductDialog(context, products, notifier, isAr),
                                  icon: const Icon(Icons.add),
                                  label: Text(isAr ? 'إضافة منتج' : 'Add Item'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (state.items.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(
                                child: Text(
                                  isAr
                                      ? 'يرجى إضافة منتج واحد على الأقل لتأكيد الطلب'
                                      : 'Add at least one product to the order',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.items.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, idx) {
                                final item = state.items[idx];
                                return ListTile(
                                  title: Text(
                                    item.productName,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${isAr ? "الكمية المطلوبة" : "Ordered"}: ${item.quantityOrdered}',
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                            if (item.quantityReceived > 0 || state.status == 'Received') ...[
                                              const SizedBox(width: 16),
                                              Text(
                                                '${isAr ? "المستلمة" : "Received"}: ${item.quantityReceived}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.green.shade800,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              '${isAr ? "تكلفة الوحدة" : "Unit Cost"}: ${item.unitCost.toStringAsFixed(2)} ${isAr ? "ج.م" : "EGP"}',
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              '${isAr ? "الإجمالي" : "Total"}: ${(item.unitCost * (state.status == "Received" ? item.quantityReceived : item.quantityOrdered)).toStringAsFixed(2)} ${isAr ? "ج.م" : "EGP"}',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: !isReadOnly
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, size: 20),
                                              onPressed: () =>
                                                  _showEditQuantityDialog(context, item, notifier, isAr),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete_outline,
                                                  color: context.colorScheme.error, size: 20),
                                              onPressed: () => notifier.removeItem(item.productId),
                                            ),
                                          ],
                                        )
                                      : null,
                                );
                              },
                            ),
                          if (state.items.isNotEmpty) ...[
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isAr ? 'إجمالي قيمة الطلب:' : 'Total Order Cost:',
                                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${totalAmount.toStringAsFixed(2)} ${isAr ? "ج.م" : "EGP"}',
                                  style: context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!isReadOnly)
                    FilledButton(
                      onPressed: state.isSubmitting || !state.isValid
                          ? null
                          : () async {
                              final err = await notifier.submit();
                              if (err == null && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      widget.editId == null
                                          ? (isAr ? 'تم حفظ أمر الشراء بنجاح' : 'Purchase Order saved successfully')
                                          : (isAr ? 'تم تعديل أمر الشراء بنجاح' : 'Purchase Order updated successfully'),
                                    ),
                                  ),
                                );
                                context.pop();
                              }
                            },
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(isAr ? 'حفظ وإرسال الأمر' : 'Save & Issue Order'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAddProductDialog(
      BuildContext context, List<ProductEntity> products, PurchaseOrderFormNotifier notifier, bool isAr) {
    ProductEntity? selectedProduct;
    final qtyController = TextEditingController(text: '10');
    final costController = TextEditingController(text: '0.00');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isAr ? 'إضافة منتج لأمر التوريد' : 'Add Product to PO'),
          content: Column(
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
                    if (val != null) {
                      costController.text = (val.price * 0.7).toStringAsFixed(2);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isAr ? 'الكمية المطلوبة' : 'Quantity Ordered',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: costController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: isAr ? 'تكلفة الوحدة' : 'Unit Cost',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            FilledButton(
              onPressed: selectedProduct == null ||
                      int.tryParse(qtyController.text) == null ||
                      double.tryParse(costController.text) == null
                  ? null
                  : () {
                      final qty = int.parse(qtyController.text);
                      final cost = double.parse(costController.text);
                      notifier.addItem(PurchaseOrderItemEntity(
                        productId: selectedProduct!.id,
                        productName: isAr ? selectedProduct!.nameAr : selectedProduct!.nameEn,
                        quantityOrdered: qty,
                        quantityReceived: 0,
                        unitCost: cost,
                      ));
                      Navigator.pop(context);
                    },
              child: Text(isAr ? 'إضافة' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditQuantityDialog(
      BuildContext context, PurchaseOrderItemEntity item, PurchaseOrderFormNotifier notifier, bool isAr) {
    final qtyController = TextEditingController(text: '${item.quantityOrdered}');
    final costController = TextEditingController(text: '${item.unitCost}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? 'تعديل بيانات المنتج' : 'Edit Item Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isAr ? 'الكمية الجديدة' : 'New Quantity',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: costController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: isAr ? 'التكلفة الجديدة' : 'New Unit Cost',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final qty = int.tryParse(qtyController.text);
              final cost = double.tryParse(costController.text);
              if (qty != null && qty > 0 && cost != null && cost >= 0) {
                notifier.updateItemQuantity(item.productId, qty, item.quantityReceived, cost);
                Navigator.pop(context);
              }
            },
            child: Text(isAr ? 'تعديل' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showReceiveDialog(
      BuildContext context, PurchaseOrderFormState state, PurchaseOrderFormNotifier notifier, bool isAr) {
    // Keep a local map of received quantities, defaulting to the quantity ordered
    final receivedQuantities = <String, int>{};
    final batchCodes = <String, String>{};
    final expiryDates = <String, DateTime>{};

    for (final item in state.items) {
      receivedQuantities[item.productId] = item.quantityOrdered;
      batchCodes[item.productId] = 'B-${(widget.editId ?? "PO").replaceAll("po_", "")}-${item.productId.replaceAll("prod_", "")}';
      expiryDates[item.productId] = DateTime.now().add(const Duration(days: 30));
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isAr ? 'تأكيد استلام المنتجات والتشغيلات' : 'Receive Items & Assign Batches'),
          content: SizedBox(
            width: 480,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, idx) {
                final item = state.items[idx];
                final currentQty = receivedQuantities[item.productId] ?? item.quantityOrdered;
                final currentCode = batchCodes[item.productId] ?? '';
                final currentExpiry = expiryDates[item.productId] ?? DateTime.now();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: '$currentQty',
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: isAr ? 'الكمية المستلمة' : 'Qty Received',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            onChanged: (val) {
                              final parsed = int.tryParse(val);
                              if (parsed != null && parsed >= 0) {
                                receivedQuantities[item.productId] = parsed;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: currentCode,
                            decoration: InputDecoration(
                              labelText: isAr ? 'رقم التشغيلة / الدفعة' : 'Batch Code',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            onChanged: (val) {
                              batchCodes[item.productId] = val.trim();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${isAr ? "الصلاحية:" : "Expiry:"} ${DateFormat('yyyy-MM-dd').format(currentExpiry)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final selected = await showDatePicker(
                              context: context,
                              initialDate: currentExpiry,
                              firstDate: DateTime.now().subtract(const Duration(days: 305)),
                              lastDate: DateTime(2030),
                            );
                            if (selected != null) {
                              setDialogState(() {
                                expiryDates[item.productId] = selected;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_month, size: 16),
                          label: Text(isAr ? 'تغيير' : 'Change'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final listToSubmit = state.items.map((item) {
                  final qtyRec = receivedQuantities[item.productId] ?? item.quantityOrdered;
                  final bCode = batchCodes[item.productId] ?? '';
                  final exp = expiryDates[item.productId] ?? DateTime.now().add(const Duration(days: 30));
                  return item.copyWith(
                    quantityReceived: qtyRec,
                    batchCode: bCode,
                    expiryDate: exp,
                  );
                }).toList();

                final err = await notifier.receiveItems(listToSubmit);
                if (context.mounted) {
                  Navigator.pop(context);
                  if (err == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isAr
                            ? 'تم استلام الشحنة وتحديث المخزون والدفعات بنجاح'
                            : 'Items received and batches registered successfully'),
                      ),
                    );
                    context.pop(); // Go back to orders list
                  }
                }
              },
              child: Text(isAr ? 'تأكيد الاستلام' : 'Confirm Receipt'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String status;
  final bool isAr;
  const _StatusTag({required this.status, required this.isAr});

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}
