import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/domain/entities/supplier.entity.dart';
import 'package:fresh_market/domain/entities/purchase_order.entity.dart';
import 'package:fresh_market/domain/entities/supplier_payment.entity.dart';
import 'package:fresh_market/data/providers/supplier_repository_provider.dart';
import 'package:fresh_market/data/providers/purchase_order_repository_provider.dart';
import 'package:fresh_market/data/providers/supplier_payment_repository_provider.dart';
import 'package:fresh_market/core/utils/result.dart';
import '../../suppliers/providers/supplier_providers.dart';
import '../../purchase_orders/providers/purchase_order_providers.dart';

class AdminSupplierDetailsPage extends ConsumerStatefulWidget {
  final String supplierId;
  const AdminSupplierDetailsPage({super.key, required this.supplierId});

  @override
  ConsumerState<AdminSupplierDetailsPage> createState() => _AdminSupplierDetailsPageState();
}

class _AdminSupplierDetailsPageState extends ConsumerState<AdminSupplierDetailsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isRtl;

    // Watch supplier stream
    final suppliersStream = ref.watch(suppliersListStreamProvider);

    // Watch POs and payments for this supplier
    final posStream = ref.watch(purchaseOrdersListStreamProvider({'supplierId': widget.supplierId}));
    final paymentsStream = ref.watch(supplierPaymentsStreamProvider(widget.supplierId));

    return suppliersStream.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('$err'))),
      data: (suppliers) {
        final supplier = suppliers.firstWhere(
          (s) => s.id == widget.supplierId,
          orElse: () => SupplierEntity(
            id: widget.supplierId,
            name: 'Unknown Supplier',
            contactPerson: '',
            phone: '',
            email: '',
            address: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(supplier.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/admin/suppliers/edit/${supplier.id}'),
                tooltip: isAr ? 'تعديل البيانات' : 'Edit Info',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: isAr ? 'كشف الحساب' : 'Ledger Ledger'),
                Tab(text: isAr ? 'أوامر الشراء' : 'Purchase Orders'),
                Tab(text: isAr ? 'المدفوعات' : 'Payments'),
              ],
            ),
          ),
          body: posStream.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('$err')),
            data: (purchaseOrders) => paymentsStream.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('$err')),
              data: (payments) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _LedgerOverview(
                      supplier: supplier,
                      purchaseOrders: purchaseOrders,
                      payments: payments,
                      isAr: isAr,
                    ),
                    _PurchaseOrdersTab(
                      purchaseOrders: purchaseOrders,
                      isAr: isAr,
                    ),
                    _PaymentsTab(
                      supplier: supplier,
                      payments: payments,
                      isAr: isAr,
                      onAddPayment: () => _showRecordPaymentDialog(context, supplier),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showRecordPaymentDialog(BuildContext context, SupplierEntity supplier) {
    showDialog(
      context: context,
      builder: (ctx) => _RecordPaymentDialog(supplier: supplier),
    );
  }
}

class _LedgerOverview extends StatelessWidget {
  final SupplierEntity supplier;
  final List<PurchaseOrderEntity> purchaseOrders;
  final List<SupplierPaymentEntity> payments;
  final bool isAr;

  const _LedgerOverview({
    required this.supplier,
    required this.purchaseOrders,
    required this.payments,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    final receivedOrders = purchaseOrders.where((po) => po.status == 'Received').toList();

    // Calculate metrics
    final totalGoodsReceived = receivedOrders.fold<double>(0, (sum, po) {
      return sum + po.items.fold<double>(0, (s, item) => s + (item.quantityReceived * item.unitCost));
    });
    final totalPaymentsMade = payments.fold<double>(0, (sum, pay) => sum + pay.amount);
    final calculatedBalance = totalGoodsReceived - totalPaymentsMade;

    // Combine transactions chronologically
    final transactions = <_LedgerEntry>[];
    for (final po in receivedOrders) {
      final poTotal = po.items.fold<double>(0, (s, item) => s + (item.quantityReceived * item.unitCost));
      transactions.add(_LedgerEntry(
        id: po.id,
        date: po.updatedAt,
        type: 'receipt',
        reference: po.id.startsWith('po_') ? '#${po.id.substring(3)}' : '#${po.id}',
        description: isAr ? 'استلام سلع أمر شراء' : 'Goods Received PO',
        debit: poTotal,
        credit: 0.0,
      ));
    }
    for (final pay in payments) {
      transactions.add(_LedgerEntry(
        id: pay.id,
        date: pay.paymentDate,
        type: 'payment',
        reference: pay.referenceNumber.isNotEmpty ? pay.referenceNumber : pay.id,
        description: isAr
            ? 'دفعة مالية (${pay.paymentMethod})'
            : 'Payment Made (${pay.paymentMethod})',
        debit: 0.0,
        credit: pay.amount,
      ));
    }

    // Sort chronologically
    transactions.sort((a, b) => a.date.compareTo(b.date));

    // Calculate running balances
    double runningBalance = 0.0;
    final processedTransactions = transactions.map((t) {
      runningBalance += t.debit - t.credit;
      return _LedgerEntryWithBalance(entry: t, runningBalance: runningBalance);
    }).toList().reversed.toList(); // Newest first for view

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Row
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: isAr ? 'الرصيد القائم' : 'Outstanding Balance',
                  value: supplier.balance,
                  color: supplier.balance > 0 ? Colors.red.shade800 : Colors.green.shade800,
                  icon: Icons.account_balance_wallet_outlined,
                  isAr: isAr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: isAr ? 'إجمالي المشتريات المستلمة' : 'Total Goods Received',
                  value: totalGoodsReceived,
                  color: Colors.blue.shade800,
                  icon: Icons.download_done_outlined,
                  isAr: isAr,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  title: isAr ? 'إجمالي المدفوعات' : 'Total Payments Made',
                  value: totalPaymentsMade,
                  color: Colors.green.shade800,
                  icon: Icons.upload_outlined,
                  isAr: isAr,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            isAr ? 'كشف الحركة المالي (دفتر الأستاذ)' : 'Financial Ledger Transaction Log',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (processedTransactions.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    isAr ? 'لا توجد حركات مسجلة' : 'No ledger movements recorded',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
            )
          else
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: processedTransactions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = processedTransactions[index];
                  final entry = item.entry;
                  final dateStr = entry.date.toLocal().toString().split(' ')[0];
                  final isPayment = entry.type == 'payment';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPayment ? Colors.green.shade50 : Colors.red.shade50,
                      child: Icon(
                        isPayment ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isPayment ? Colors.green.shade700 : Colors.red.shade700,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      entry.description,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${isAr ? "التاريخ" : "Date"}: $dateStr | ${isAr ? "المرجع" : "Ref"}: ${entry.reference}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isPayment
                              ? '-${entry.credit.toStringAsFixed(2)} ${isAr ? "ج.م" : "EGP"}'
                              : '+${entry.debit.toStringAsFixed(2)} ${isAr ? "ج.م" : "EGP"}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isPayment ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${isAr ? "الرصيد" : "Bal"}: ${item.runningBalance.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _LedgerEntry {
  final String id;
  final DateTime date;
  final String type; // 'receipt' or 'payment'
  final String reference;
  final String description;
  final double debit;
  final double credit;

  const _LedgerEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.reference,
    required this.description,
    required this.debit,
    required this.credit,
  });
}

class _LedgerEntryWithBalance {
  final _LedgerEntry entry;
  final double runningBalance;
  const _LedgerEntryWithBalance({required this.entry, required this.runningBalance});
}

class _MetricCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  final IconData icon;
  final bool isAr;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${value.toStringAsFixed(2)} ${isAr ? "ج.م" : "EGP"}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseOrdersTab extends StatelessWidget {
  final List<PurchaseOrderEntity> purchaseOrders;
  final bool isAr;

  const _PurchaseOrdersTab({required this.purchaseOrders, required this.isAr});

  @override
  Widget build(BuildContext context) {
    if (purchaseOrders.isEmpty) {
      return Center(
        child: Text(
          isAr ? 'لا توجد طلبات شراء مسجلة' : 'No Purchase Orders logged',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: purchaseOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final po = purchaseOrders[index];
        final dateStr = po.createdAt.toLocal().toString().split(' ')[0];
        final qty = po.items.fold<int>(0, (sum, item) => sum + item.quantityOrdered);
        final cost = po.items.fold<double>(0, (sum, item) {
          final amt = po.status == 'Received' ? item.quantityReceived : item.quantityOrdered;
          return sum + (amt * item.unitCost);
        });

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onTap: () => context.push('/admin/purchase-orders/edit/${po.id}'),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  po.id.startsWith('po_') ? '#${po.id.substring(3)}' : '#${po.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _poStatusChip(po.status),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${isAr ? "تاريخ:" : "Date:"} $dateStr | ${isAr ? "الكمية:" : "Qty:"} $qty',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    '${cost.toStringAsFixed(2)} ${isAr ? "ج.م" : "EGP"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _poStatusChip(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Pending':
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
      case 'Ordered':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
      case 'Received':
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
      default:
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _PaymentsTab extends ConsumerWidget {
  final SupplierEntity supplier;
  final List<SupplierPaymentEntity> payments;
  final bool isAr;
  final VoidCallback onAddPayment;

  const _PaymentsTab({
    required this.supplier,
    required this.payments,
    required this.isAr,
    required this.onAddPayment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAddPayment,
              icon: const Icon(Icons.payment),
              label: Text(isAr ? 'تسجيل دفعة مالية للمورد' : 'Record Supplier Payment'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
        Expanded(
          child: payments.isEmpty
              ? Center(
                  child: Text(
                    isAr ? 'لا توجد دفعات مالية مسجلة' : 'No payments logged yet',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: payments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final pay = payments[index];
                    final dateStr = pay.paymentDate.toLocal().toString().split(' ')[0];

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(Icons.upload, color: Colors.green.shade800),
                        ),
                        title: Text(
                          '${pay.amount.toStringAsFixed(2)} ${isAr ? "ج.م" : "EGP"}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${isAr ? "طريقة الدفع" : "Method"}: ${pay.paymentMethod} | ${isAr ? "التاريخ" : "Date"}: $dateStr',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (pay.referenceNumber.isNotEmpty)
                                Text(
                                  '${isAr ? "رقم المرجع" : "Ref"}: ${pay.referenceNumber}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              if (pay.notes.isNotEmpty)
                                Text(
                                  '${isAr ? "ملاحظات" : "Notes"}: ${pay.notes}',
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(isAr ? 'حذف الدفعة المالية؟' : 'Delete Payment?'),
                                content: Text(
                                  isAr
                                      ? 'هل أنت متأكد من رغبتك في حذف هذه الدفعة وإعادة الرصيد المستحق للمورد؟'
                                      : 'Are you sure you want to delete this payment record? The supplier balance will be adjusted.',
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
                              await ref.read(supplierPaymentRepositoryProvider).deletePayment(pay.id);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RecordPaymentDialog extends ConsumerStatefulWidget {
  final SupplierEntity supplier;
  const _RecordPaymentDialog({required this.supplier});

  @override
  ConsumerState<_RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<_RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _refController;
  late TextEditingController _notesController;
  String _selectedMethod = 'Cash';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _refController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isRtl;
    final params = SupplierPayParams(widget.supplier.id, widget.supplier.name);
    final formState = ref.watch(supplierPaymentFormProvider(params));
    final notifier = ref.read(supplierPaymentFormProvider(params).notifier);

    return AlertDialog(
      title: Text(isAr ? 'تسجيل دفعة مالية للمورد' : 'Record Supplier Payment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (formState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red.shade50,
                  child: Text(
                    formState.errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: isAr ? 'المبلغ *' : 'Amount *',
                  suffixText: isAr ? 'ج.م' : 'EGP',
                  border: const OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return isAr ? 'مطلوب' : 'Required';
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed <= 0) return isAr ? 'مبلغ غير صالح' : 'Invalid amount';
                  return null;
                },
                onChanged: (val) {
                  final parsed = double.tryParse(val) ?? 0.0;
                  notifier.setAmount(parsed);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedMethod,
                decoration: InputDecoration(
                  labelText: isAr ? 'طريقة الدفع' : 'Payment Method',
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'Cash', child: Text(isAr ? 'نقدي' : 'Cash')),
                  DropdownMenuItem(value: 'Bank Transfer', child: Text(isAr ? 'تحويل بنكي' : 'Bank Transfer')),
                  DropdownMenuItem(value: 'Check', child: Text(isAr ? 'شيك' : 'Check')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedMethod = val;
                    });
                    notifier.setPaymentMethod(val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _refController,
                decoration: InputDecoration(
                  labelText: isAr ? 'رقم الإيصال / المرجع' : 'Receipt / Ref Number',
                  border: const OutlineInputBorder(),
                ),
                onChanged: notifier.setReferenceNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: isAr ? 'ملاحظات إضافية' : 'Notes',
                  border: const OutlineInputBorder(),
                ),
                onChanged: notifier.setNotes,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: formState.isSubmitting ? null : () => Navigator.pop(context),
          child: Text(isAr ? 'إلغاء' : 'Cancel'),
        ),
        FilledButton(
          onPressed: formState.isSubmitting
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    final err = await notifier.submit();
                    if (err == null && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAr ? 'تم تسجيل الدفعة بنجاح' : 'Payment recorded successfully',
                          ),
                        ),
                      );
                    }
                  }
                },
          child: formState.isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(isAr ? 'تسجيل' : 'Record'),
        ),
      ],
    );
  }
}
