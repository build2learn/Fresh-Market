import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/file_saver/file_saver.dart';
import 'package:fresh_market/core/utils/report_generator/report_generator.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/providers/audit_log_repository_provider.dart';
import 'package:fresh_market/data/providers/category_repository_provider.dart';
import 'package:fresh_market/data/providers/order_repository_provider.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/data/providers/user_repository_provider.dart';
import 'package:fresh_market/domain/entities/audit_log.entity.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/domain/entities/order.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/entities/user.entity.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';
import 'package:intl/intl.dart';

class AdminReportsPage extends ConsumerStatefulWidget {
  const AdminReportsPage({super.key});

  @override
  ConsumerState<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends ConsumerState<AdminReportsPage> {
  ReportType _reportType = ReportType.orders;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategoryId;
  String? _selectedCustomerId;
  bool _isLoading = false;

  List<OrderEntity> _orders = [];
  List<ProductEntity> _products = [];
  List<CategoryEntity> _categories = [];
  List<UserEntity> _customers = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchInitialData());
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    final orderRepo = ref.read(orderRepositoryProvider);
    final productRepo = ref.read(productRepositoryProvider);
    final categoryRepo = ref.read(categoryRepositoryProvider);
    final userRepo = ref.read(userRepositoryProvider);

    final ordersRes = await orderRepo.getOrders();
    final productsRes = await productRepo.getProducts(limit: 1000);
    final categoriesRes = await categoryRepo.getCategories();
    final usersRes = await userRepo.getUsers(limit: 100);

    if (mounted) {
      setState(() {
        if (ordersRes is Success<List<OrderEntity>>) _orders = ordersRes.data;
        if (productsRes is Success<List<ProductEntity>>) _products = productsRes.data;
        if (categoriesRes is Success<List<CategoryEntity>>) _categories = categoriesRes.data;
        if (usersRes is Success<List<UserEntity>>) {
          _customers = usersRes.data.where((u) => u.isCustomer).toList();
        }
        _isLoading = false;
      });
    }
  }

  List<dynamic> _getFilteredData() {
    switch (_reportType) {
      case ReportType.orders:
      case ReportType.revenue:
        var list = _orders;
        if (_selectedCustomerId != null) {
          list = list.where((o) => o.customerId == _selectedCustomerId).toList();
        }
        if (_startDate != null) {
          list = list.where((o) => o.createdAt.isAfter(_startDate!) || o.createdAt.isAtSameMomentAs(_startDate!)).toList();
        }
        if (_endDate != null) {
          // add 1 day to match end of day
          final endBound = _endDate!.add(const Duration(days: 1));
          list = list.where((o) => o.createdAt.isBefore(endBound)).toList();
        }
        if (_reportType == ReportType.revenue) {
          // For Revenue, we filter only delivered orders.
          list = list.where((o) => o.status == 'Delivered').toList();
          
          if (_selectedCategoryId != null) {
            // Include only orders that have items in the selected category
            list = list.where((o) {
              return o.items.any((item) {
                final p = _products.firstWhere((prod) => prod.id == item.productId, orElse: () => _products.first);
                return p.categoryId == _selectedCategoryId;
              });
            }).toList();
          }
        }
        return list;

      case ReportType.products:
      case ReportType.inventory:
        var list = _products;
        if (_selectedCategoryId != null) {
          list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
        }
        return list;
    }
  }

  Future<void> _exportReport(String format) async {
    final filtered = _getFilteredData();
    if (filtered.isEmpty) {
      context.showSnackBar(
        context.isRtl ? 'لا يوجد بيانات لتصديرها وفقاً للمرشحات الحالية' : 'No data available to export with current filters',
        isError: true,
      );
      return;
    }

    final String fileName = 'report_${_reportType.name}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.$format';
    final List<int> bytes;
    final String mimeType;

    switch (format) {
      case 'csv':
        bytes = ReportGenerator.generateCSV(_reportType, filtered);
        mimeType = 'text/csv';
        break;
      case 'xls':
        bytes = ReportGenerator.generateExcel(_reportType, filtered);
        mimeType = 'application/vnd.ms-excel';
        break;
      case 'pdf':
        bytes = ReportGenerator.generatePDF(_reportType, filtered);
        mimeType = 'application/pdf';
        break;
      default:
        return;
    }

    await FileSaver.saveFile(bytes, fileName, mimeType);

    // Audit log logging
    try {
      final auditRepo = ref.read(auditLogRepositoryProvider);
      final user = ref.read(currentUserProvider);
      await auditRepo.createAuditLog(
        AuditLogEntity(
          id: '',
          userId: user?.id ?? 'system',
          userEmail: user?.email ?? 'system',
          action: 'Export Report',
          details: 'Exported ${_reportType.name.toUpperCase()} as ${format.toUpperCase()}',
          timestamp: DateTime.now(),
        ),
      );
    } catch (_) {}

    if (mounted) {
      context.showSnackBar(
        context.isRtl ? 'تم تصدير التقرير وتحميله بنجاح!' : 'Report exported and downloaded successfully!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isRtl;
    final filtered = _getFilteredData();

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'التقارير والتصدير' : 'Reports & Exports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchInitialData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFiltersSection(context),
                      const SizedBox(height: 24),
                      _buildExportButtons(context),
                      const SizedBox(height: 24),
                      _buildPreviewTable(context, filtered),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildFiltersSection(BuildContext context) {
    final isAr = context.isRtl;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'مرشحات التقرير' : 'Report Filters',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Report Type Dropdown
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<ReportType>(
                    value: _reportType,
                    decoration: InputDecoration(
                      labelText: isAr ? 'نوع التقرير' : 'Report Type',
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: ReportType.orders,
                        child: Text(isAr ? 'تقرير الطلبات' : 'Orders Report'),
                      ),
                      DropdownMenuItem(
                        value: ReportType.revenue,
                        child: Text(isAr ? 'تقرير الإيرادات' : 'Revenue Report'),
                      ),
                      DropdownMenuItem(
                        value: ReportType.products,
                        child: Text(isAr ? 'تقرير المنتجات' : 'Products Report'),
                      ),
                      DropdownMenuItem(
                        value: ReportType.inventory,
                        child: Text(isAr ? 'تقرير المخزون' : 'Inventory Report'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _reportType = val;
                          // clear customer/date filters if not relevant to product/inventory
                          if (val == ReportType.products || val == ReportType.inventory) {
                            _selectedCustomerId = null;
                            _startDate = null;
                            _endDate = null;
                          }
                        });
                      }
                    },
                  ),
                ),

                // Category Filter (except for Orders report)
                if (_reportType != ReportType.orders)
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String?>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: isAr ? 'الفئة' : 'Category',
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          child: Text(isAr ? 'جميع الفئات' : 'All Categories'),
                        ),
                        ..._categories.map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(isAr ? c.nameAr : c.nameEn),
                            ),),
                      ],
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                    ),
                  ),

                // Customer Filter (only for Orders & Revenue)
                if (_reportType == ReportType.orders || _reportType == ReportType.revenue)
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String?>(
                      value: _selectedCustomerId,
                      decoration: InputDecoration(
                        labelText: isAr ? 'العميل' : 'Customer',
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          child: Text(isAr ? 'جميع العملاء' : 'All Customers'),
                        ),
                        ..._customers.map((cust) => DropdownMenuItem(
                              value: cust.id,
                              child: Text(cust.displayName ?? cust.email),
                            ),),
                      ],
                      onChanged: (val) => setState(() => _selectedCustomerId = val),
                    ),
                  ),

                // Date Picker trigger (only for Orders & Revenue)
                if (_reportType == ReportType.orders || _reportType == ReportType.revenue) ...[
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                        initialDateRange: _startDate != null && _endDate != null
                            ? DateTimeRange(start: _startDate!, end: _endDate!)
                            : null,
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked.start;
                          _endDate = picked.end;
                        });
                      }
                    },
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _startDate == null || _endDate == null
                          ? (isAr ? 'اختر الفترة الزمنية' : 'Select Date Range')
                          : '${DateFormat.yMMMd(isAr ? 'ar' : 'en').format(_startDate!)} - ${DateFormat.yMMMd(isAr ? 'ar' : 'en').format(_endDate!)}',
                    ),
                  ),
                  if (_startDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                        });
                      },
                    ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButtons(BuildContext context) {
    final isAr = context.isRtl;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade50,
              foregroundColor: Colors.green.shade800,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.grid_on_outlined),
            label: Text(isAr ? 'تصدير Excel' : 'Export Excel'),
            onPressed: () => _exportReport('xls'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: Colors.orange.shade800,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.text_snippet_outlined),
            label: Text(isAr ? 'تصدير CSV' : 'Export CSV'),
            onPressed: () => _exportReport('csv'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade800,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(isAr ? 'تصدير PDF' : 'Export PDF'),
            onPressed: () => _exportReport('pdf'),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewTable(BuildContext context, List<dynamic> filtered) {
    final isAr = context.isRtl;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'معاينة البيانات (أول 10 صفوف)' : 'Data Preview (First 10 rows)',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  isAr ? 'إجمالي السجلات: ${filtered.length}' : 'Total Records: ${filtered.length}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const Divider(height: 24),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    isAr ? 'لا توجد سجلات مطابقة للبحث' : 'No records match search filters',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: _getPreviewColumns(),
                    rows: _getPreviewRows(filtered.take(10).toList()),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<DataColumn> _getPreviewColumns() {
    final isAr = context.isRtl;
    switch (_reportType) {
      case ReportType.orders:
        return [
          DataColumn(label: Text(isAr ? 'رقم الطلب' : 'Order No')),
          DataColumn(label: Text(isAr ? 'العميل' : 'Customer')),
          DataColumn(label: Text(isAr ? 'التاريخ' : 'Date')),
          DataColumn(label: Text(isAr ? 'الإجمالي' : 'Total')),
          DataColumn(label: Text(isAr ? 'الحالة' : 'Status')),
        ];
      case ReportType.revenue:
        return [
          DataColumn(label: Text(isAr ? 'التاريخ' : 'Date')),
          DataColumn(label: Text(isAr ? 'عدد الطلبات' : 'Orders Count')),
          DataColumn(label: Text(isAr ? 'صافي الإيرادات' : 'Net Revenue')),
        ];
      case ReportType.products:
        return [
          DataColumn(label: Text(isAr ? 'المنتج' : 'Product')),
          DataColumn(label: Text(isAr ? 'الفئة' : 'Category')),
          DataColumn(label: Text(isAr ? 'السعر' : 'Price')),
          DataColumn(label: Text(isAr ? 'المخزون المتوفر' : 'Stock')),
        ];
      case ReportType.inventory:
        return [
          DataColumn(label: Text(isAr ? 'المنتج' : 'Product')),
          DataColumn(label: Text(isAr ? 'المخزون الحالي' : 'Current Stock')),
          DataColumn(label: Text(isAr ? 'المتوفر' : 'Available')),
          DataColumn(label: Text(isAr ? 'الحالة' : 'Status')),
        ];
    }
  }

  List<DataRow> _getPreviewRows(List<dynamic> previewList) {
    final isAr = context.isRtl;
    switch (_reportType) {
      case ReportType.orders:
        return previewList.cast<OrderEntity>().map((o) {
          return DataRow(
            cells: [
              DataCell(Text(o.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(o.customerName)),
              DataCell(Text(DateFormat.yMMMd(isAr ? 'ar' : 'en').format(o.createdAt))),
              DataCell(Text(context.formatPrice(o.total))),
              DataCell(Text(o.status)),
            ],
          );
        }).toList();
      case ReportType.revenue:
        // Group by Date for revenue preview
        final orders = previewList.cast<OrderEntity>();
        final groups = <String, List<OrderEntity>>{};
        for (final o in orders) {
          final dayStr = DateFormat('yyyy-MM-dd').format(o.createdAt);
          groups.putIfAbsent(dayStr, () => []).add(o);
        }
        final sortedKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
        return sortedKeys.map((dayStr) {
          final grp = groups[dayStr]!;
          final total = grp.fold<double>(0, (sum, o) => sum + o.total);
          return DataRow(
            cells: [
              DataCell(Text(dayStr)),
              DataCell(Text('${grp.length}')),
              DataCell(Text(context.formatPrice(total))),
            ],
          );
        }).toList();
      case ReportType.products:
        return previewList.cast<ProductEntity>().map((p) {
          final catIndex = _categories.indexWhere((c) => c.id == p.categoryId);
          final catName = catIndex != -1
              ? (isAr ? _categories[catIndex].nameAr : _categories[catIndex].nameEn)
              : (isAr ? 'غير معروف' : 'N/A');
          return DataRow(
            cells: [
              DataCell(Text(isAr ? p.nameAr : p.nameEn, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(catName)),
              DataCell(Text(context.formatPrice(p.price))),
              DataCell(Text('${p.availableStock}')),
            ],
          );
        }).toList();
      case ReportType.inventory:
        return previewList.cast<ProductEntity>().map((p) {
          final status = p.availableStock <= 0
              ? (isAr ? 'نفذ المخزون' : 'Out of Stock')
              : (p.availableStock <= p.minimumStock ? (isAr ? 'مخزون منخفض' : 'Low Stock') : (isAr ? 'سليم' : 'Healthy'));
          final statusCol = p.availableStock <= 0
              ? Colors.red
              : (p.availableStock <= p.minimumStock ? Colors.orange : Colors.green);
          return DataRow(
            cells: [
              DataCell(Text(isAr ? p.nameAr : p.nameEn, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text('${p.currentStock}')),
              DataCell(Text('${p.availableStock}')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusCol.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusCol, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ),
            ],
          );
        }).toList();
    }
  }
}
