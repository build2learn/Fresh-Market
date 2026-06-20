import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';

class AdminTreasuryPage extends ConsumerWidget {
  const AdminTreasuryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'الخزينة والمالية' : 'Treasury & Cash Control'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Treasury Balances Cards
            _buildTreasuryBalances(context),
            const SizedBox(height: 24),

            // Cash Drawer Reconciliations + Payment Methods
            if (context.isMobile) ...[
              _buildPaymentMethodsBreakdown(context),
              const SizedBox(height: 24),
              _buildDrawerReconciliations(context),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildPaymentMethodsBreakdown(context),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: _buildDrawerReconciliations(context),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Recent Cashflow Transactions
            _buildRecentTransactions(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTreasuryBalances(BuildContext context) {
    final isAr = context.isRtl;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildBalanceCard(
          context,
          title: isAr ? 'رصيد الخزينة الإجمالي' : 'Total Treasury Balance',
          value: 'EGP 342,850.00',
          subtitle: isAr ? 'السيولة النقدية المتوفرة' : 'Available liquid assets',
          icon: Icons.account_balance,
          color: Colors.teal,
        ),
        _buildBalanceCard(
          context,
          title: isAr ? 'النقد في حوزة السائقين (تحصيل)' : 'Cash in Hand (Drivers)',
          value: 'EGP 24,150.00',
          subtitle: isAr ? 'بانتظار تسوية الورديات' : 'Pending shift settlement',
          icon: Icons.payments_outlined,
          color: Colors.orange,
        ),
        _buildBalanceCard(
          context,
          title: isAr ? 'الحساب البنكي / المدفوعات' : 'Bank Balance (Card)',
          value: 'EGP 318,700.00',
          subtitle: isAr ? 'المدفوعات الإلكترونية المستلمة' : 'Online card payouts settled',
          icon: Icons.credit_card_outlined,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final cardWidth = context.isMobile 
        ? (MediaQuery.of(context).size.width - 48) / 2 
        : (MediaQuery.of(context).size.width - 68) / 3;

    return SizedBox(
      width: cardWidth.clamp(160.0, double.infinity),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(icon, color: color, size: 24),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsBreakdown(BuildContext context) {
    final isAr = context.isRtl;

    final methods = [
      _PaymentMethod('Cash on Delivery', isAr ? 'الدفع عند الاستلام' : 'Cash on Delivery', 0.65, 'EGP 222,852.50', Colors.teal),
      _PaymentMethod('Credit/Debit Card', isAr ? 'البطاقة الائتمانية' : 'Credit/Debit Card', 0.28, 'EGP 96,000.00', Colors.blue),
      _PaymentMethod('InstaPay / Wallet', isAr ? 'محفظة إلكترونية' : 'InstaPay / Wallet', 0.07, 'EGP 23,997.50', Colors.orange),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'توزيع طرق الدفع للمبيعات' : 'Sales Payment Methods',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: methods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final m = methods[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? m.nameAr : m.nameEn,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          m.amount,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: m.percentage,
                              color: m.color,
                              backgroundColor: m.color.withOpacity(0.1),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(m.percentage * 100).toInt()}%',
                          style: TextStyle(color: m.color, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerReconciliations(BuildContext context) {
    final isAr = context.isRtl;

    final drawers = [
      _DrawerShift('Shift #124', 'Amr H. (Driver)', 'EGP 8,400', 'EGP 8,400', 'EGP 0', 'Settled', Colors.green),
      _DrawerShift('Shift #125', 'Tarek F. (Driver)', 'EGP 4,200', 'EGP 4,150', '-EGP 50', 'Reconciled (Deficit)', Colors.orange),
      _DrawerShift('Shift #126', 'Karim A. (Driver)', 'EGP 11,550', 'EGP 11,550', 'EGP 0', 'Settled', Colors.green),
      _DrawerShift('Shift #127', 'Ahmed M. (Cashier)', 'EGP 55,000', 'EGP --', 'EGP --', 'Open / Active', Colors.blue),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'تسوية عهد وورديات النقدية' : 'Shift Cash Drawer Settlements',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(isAr ? 'تسوية وردية' : 'Reconcile Shift'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(isAr ? 'الوردية' : 'Shift / Drawer')),
                  DataColumn(label: Text(isAr ? 'الموظف' : 'Custodian')),
                  DataColumn(label: Text(isAr ? 'المتوقع' : 'Expected')),
                  DataColumn(label: Text(isAr ? 'الفعلي' : 'Actual Cash')),
                  DataColumn(label: Text(isAr ? 'الفارق' : 'Discrepancy')),
                  DataColumn(label: Text(isAr ? 'الحالة' : 'Status')),
                ],
                rows: drawers.map((d) {
                  return DataRow(
                    cells: [
                      DataCell(Text(d.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(d.custodian)),
                      DataCell(Text(d.expected)),
                      DataCell(Text(d.actual)),
                      DataCell(Text(
                        d.discrepancy,
                        style: TextStyle(
                          color: d.discrepancy.startsWith('-') ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: d.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            d.status,
                            style: TextStyle(color: d.statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final isAr = context.isRtl;

    final transactions = [
      _Transaction('#TX-4809', 'Customer Order EGP', 'EGP 840.00', 'Inflow', 'InstaPay', 'Today, 2:15 AM', Colors.green),
      _Transaction('#TX-4808', 'Supplier Payout: FreshFarm Ltd.', '-EGP 15,200.00', 'Outflow', 'Bank Transfer', 'Today, 1:00 AM', Colors.red),
      _Transaction('#TX-4807', 'Driver Cash Settlement: Amr H.', 'EGP 8,400.00', 'Inflow', 'Cash Drawer', 'Yesterday, 11:30 PM', Colors.green),
      _Transaction('#TX-4806', 'Customer Order COD', 'EGP 1,220.00', 'Inflow', 'Cash Drawer', 'Yesterday, 9:45 PM', Colors.green),
      _Transaction('#TX-4805', 'Office Expenses & Stationary', '-EGP 320.00', 'Outflow', 'Petty Cash', 'Yesterday, 4:00 PM', Colors.red),
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'حركة المعاملات المالية الأخيرة' : 'Recent Financial Transactions',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: Text(isAr ? 'تصدير كشف حساب' : 'Export Statement'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(isAr ? 'المرجع' : 'Reference')),
                  DataColumn(label: Text(isAr ? 'البيان' : 'Description')),
                  DataColumn(label: Text(isAr ? 'القيمة' : 'Amount')),
                  DataColumn(label: Text(isAr ? 'النوع' : 'Type')),
                  DataColumn(label: Text(isAr ? 'الوسيلة' : 'Method')),
                  DataColumn(label: Text(isAr ? 'التاريخ' : 'Date & Time')),
                ],
                rows: transactions.map((t) {
                  final isInflow = t.type == 'Inflow';
                  return DataRow(
                    cells: [
                      DataCell(Text(t.ref, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(t.desc)),
                      DataCell(Text(
                        t.amount,
                        style: TextStyle(
                          color: isInflow ? Colors.green.shade800 : Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                      DataCell(Text(
                        isInflow ? (isAr ? 'وارد / إيراد' : 'Inflow') : (isAr ? 'صادر / مصروف' : 'Outflow'),
                        style: TextStyle(color: isInflow ? Colors.green : Colors.red),
                      )),
                      DataCell(Text(t.method)),
                      DataCell(Text(t.time)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethod {
  final String nameEn;
  final String nameAr;
  final double percentage;
  final String amount;
  final Color color;

  _PaymentMethod(this.nameEn, this.nameAr, this.percentage, this.amount, this.color);
}

class _DrawerShift {
  final String id;
  final String custodian;
  final String expected;
  final String actual;
  final String discrepancy;
  final String status;
  final Color statusColor;

  _DrawerShift(this.id, this.custodian, this.expected, this.actual, this.discrepancy, this.status, this.statusColor);
}

class _Transaction {
  final String ref;
  final String desc;
  final String amount;
  final String type;
  final String method;
  final String time;
  final Color typeColor;

  _Transaction(this.ref, this.desc, this.amount, this.type, this.method, this.time, this.typeColor);
}
