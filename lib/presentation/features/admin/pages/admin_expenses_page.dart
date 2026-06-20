import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../domain/entities/expense.entity.dart';
import '../../../../data/providers/expense_repository_provider.dart';
import '../../../../core/utils/result.dart';
import '../providers/expense_providers.dart';

class AdminExpensesPage extends ConsumerStatefulWidget {
  const AdminExpensesPage({super.key});

  @override
  ConsumerState<AdminExpensesPage> createState() => _AdminExpensesPageState();
}

class _AdminExpensesPageState extends ConsumerState<AdminExpensesPage> {
  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'Rent',
    'Salaries',
    'Fuel',
    'Electricity',
    'Internet',
    'Maintenance',
  ];

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesListStreamProvider);
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'إدارة المصروفات' : 'Expense Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(expensesListStreamProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(expensesListStreamProvider),
        child: expensesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('$err')),
          data: (expenses) {
            // Apply category filter & search filter
            final filtered = expenses.where((e) {
              final matchesCategory = _selectedCategoryFilter == 'All' || e.category == _selectedCategoryFilter;
              final matchesQuery = e.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  e.category.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchesCategory && matchesQuery;
            }).toList();

            // Calculate Metrics
            double totalEGP = 0.0;
            double totalEGPThisMonth = 0.0;
            final now = DateTime.now();

            for (final e in expenses) {
              // Convert both EGP and E£ 1:1 since they represent the same currency
              totalEGP += e.amount;
              if (e.expenseDate.year == now.year && e.expenseDate.month == now.month) {
                totalEGPThisMonth += e.amount;
              }
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Metrics Summary Layout
                _buildMetricsRow(context, totalEGP, totalEGPThisMonth, expenses.length, isAr),
                const SizedBox(height: 24),

                // Controls: Search bar & category filter chips
                _buildControls(context, isAr),
                const SizedBox(height: 16),

                // Expense list
                if (filtered.isEmpty)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          isAr ? 'لا توجد مصروفات مسجلة مطابقة للبحث' : 'No expenses match search criteria',
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
                    itemBuilder: (context, idx) {
                      final item = filtered[idx];
                      return _buildExpenseCard(context, item, isAr);
                    },
                  ),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditExpenseDialog(context, null, isAr),
        icon: const Icon(Icons.add),
        label: Text(isAr ? 'إضافة مصروف' : 'Add Expense'),
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, double total, double monthly, int count, bool isAr) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return GridView.count(
          crossAxisCount: isMobile ? 3 : 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isMobile ? 0.95 : 1.9,
          children: [
            _buildStatCard(
              title: isAr ? 'إجمالي المصاريف' : 'Total Expenses',
              value: '${total.toStringAsFixed(0)} EGP',
              icon: Icons.money_off,
              color: Colors.red.shade700,
            ),
            _buildStatCard(
              title: isAr ? 'مصاريف هذا الشهر' : 'Month-to-Date',
              value: '${monthly.toStringAsFixed(0)} EGP',
              icon: Icons.calendar_month,
              color: Colors.orange.shade800,
            ),
            _buildStatCard(
              title: isAr ? 'عدد السجلات' : 'Total Transactions',
              value: '$count',
              icon: Icons.receipt_long,
              color: Colors.blue.shade700,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: isAr ? 'البحث في التفاصيل...' : 'Search by description...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', isAr ? 'الكل' : 'All'),
              ..._categories.map((c) => _buildFilterChip(c, isAr ? _translateCategory(c) : c)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedCategoryFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedCategoryFilter = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, ExpenseEntity item, bool isAr) {
    final dateFormatted = DateFormat('yyyy-MM-dd').format(item.expenseDate);
    final categoryColor = _getCategoryColor(item.category);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isAr ? _translateCategory(item.category) : item.category,
                          style: TextStyle(
                            color: categoryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormatted,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description.isNotEmpty ? item.description : (isAr ? 'لا يوجد تفاصيل' : 'No description provided'),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.amount.toStringAsFixed(2)} ${item.currency}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _showAddEditExpenseDialog(context, item, isAr),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: context.colorScheme.error, size: 20),
                      onPressed: () => _confirmDeleteExpense(item.id, isAr),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Rent':
        return Colors.purple.shade700;
      case 'Salaries':
        return Colors.green.shade700;
      case 'Fuel':
        return Colors.orange.shade800;
      case 'Electricity':
        return Colors.amber.shade800;
      case 'Internet':
        return Colors.blue.shade700;
      case 'Maintenance':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  String _translateCategory(String cat) {
    switch (cat) {
      case 'Rent':
        return 'إيجار';
      case 'Salaries':
        return 'رواتب';
      case 'Fuel':
        return 'وقود / بنزين';
      case 'Electricity':
        return 'كهرباء';
      case 'Internet':
        return 'إنترنت';
      case 'Maintenance':
        return 'صيانة';
      default:
        return cat;
    }
  }

  void _showAddEditExpenseDialog(BuildContext context, ExpenseEntity? editItem, bool isAr) {
    final isEdit = editItem != null;
    String selectedCat = editItem?.category ?? 'Rent';
    String selectedCurrency = editItem?.currency ?? 'EGP';
    final amountController = TextEditingController(text: editItem != null ? '${editItem.amount}' : '');
    final descController = TextEditingController(text: editItem?.description ?? '');
    DateTime selectedDate = editItem?.expenseDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            isEdit
                ? (isAr ? 'تعديل المصروف' : 'Edit Expense')
                : (isAr ? 'إضافة مصروف جديد' : 'New Expense'),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCat,
                  decoration: InputDecoration(
                    labelText: isAr ? 'التصنيف / الفئة' : 'Category',
                    border: const OutlineInputBorder(),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(isAr ? _translateCategory(c) : c),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedCat = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: isAr ? 'المبلغ' : 'Amount',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: selectedCurrency,
                        decoration: InputDecoration(
                          labelText: isAr ? 'العملة' : 'Currency',
                          border: const OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'EGP', child: Text('EGP')),
                          DropdownMenuItem(value: 'E£', child: Text('E£')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedCurrency = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: isAr ? 'التفاصيل / البيان' : 'Description',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${isAr ? "التاريخ:" : "Date:"} ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (selected != null) {
                          setDialogState(() => selectedDate = selected);
                        }
                      },
                      icon: const Icon(Icons.calendar_month, size: 16),
                      label: Text(isAr ? 'تغيير' : 'Change'),
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
              onPressed: () async {
                final amt = double.tryParse(amountController.text);
                if (amt == null || amt <= 0) return;

                final expense = ExpenseEntity(
                  id: editItem?.id ?? '',
                  category: selectedCat,
                  amount: amt,
                  currency: selectedCurrency,
                  expenseDate: selectedDate,
                  description: descController.text.trim(),
                  createdAt: editItem?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                final repo = ref.read(expenseRepositoryProvider);
                final Result res = isEdit
                    ? await repo.updateExpense(expense)
                    : await repo.createExpense(expense);

                if (res is Success && context.mounted) {
                  Navigator.pop(ctx);
                  ref.invalidate(expensesListStreamProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAr
                            ? 'تم حفظ المصروف بنجاح'
                            : 'Expense saved successfully',
                      ),
                    ),
                  );
                }
              },
              child: Text(isAr ? 'حفظ' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteExpense(String id, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'حذف المصروف؟' : 'Delete Expense?'),
        content: Text(
          isAr
              ? 'هل أنت متأكد من رغبتك في حذف هذا المصروف نهائياً؟'
              : 'Are you sure you want to permanently delete this expense?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final repo = ref.read(expenseRepositoryProvider);
              final res = await repo.deleteExpense(id);
              if (res is Success && context.mounted) {
                Navigator.pop(ctx);
                ref.invalidate(expensesListStreamProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAr
                          ? 'تم حذف المصروف بنجاح'
                          : 'Expense deleted successfully',
                    ),
                  ),
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
