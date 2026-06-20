import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../domain/entities/warehouse.entity.dart';
import '../../../../domain/entities/warehouse_inventory.entity.dart';
import '../../../../domain/entities/stock_transfer.entity.dart';
import '../../../../domain/entities/product.entity.dart';
import 'package:fresh_market/presentation/features/admin/providers/warehouse_providers.dart';
import 'package:fresh_market/presentation/features/products/providers/product_providers.dart';
import 'package:fresh_market/presentation/features/products/providers/product_list_provider.dart';

class AdminWarehousePage extends ConsumerStatefulWidget {
  const AdminWarehousePage({super.key});

  @override
  ConsumerState<AdminWarehousePage> createState() => _AdminWarehousePageState();
}

class _AdminWarehousePageState extends ConsumerState<AdminWarehousePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchWarehouseController = TextEditingController();
  final _searchInventoryController = TextEditingController();
  String _warehouseQuery = '';
  String _inventoryQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListProvider.notifier).startRealtimeSync();
    });
    _searchWarehouseController.addListener(() {
      setState(() {
        _warehouseQuery = _searchWarehouseController.text.trim();
      });
    });
    _searchInventoryController.addListener(() {
      setState(() {
        _inventoryQuery = _searchInventoryController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchWarehouseController.dispose();
    _searchInventoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isRtl;
    final warehousesAsync = ref.watch(warehousesListStreamProvider);
    final inventoriesAsync = ref.watch(warehouseInventoriesStreamProvider);
    final transfersAsync = ref.watch(stockTransfersStreamProvider);
    final productState = ref.watch(productListProvider);

    // Dynamic error/loading banner from Notifier
    ref.listen<AsyncValue<void>>(warehouseNotifierProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'إدارة المستودعات والنقل' : 'Warehouse & Stock Transfer'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.store_outlined),
              text: isAr ? 'المستودعات' : 'Warehouses',
            ),
            Tab(
              icon: const Icon(Icons.inventory_2_outlined),
              text: isAr ? 'المخزون الداخلي' : 'Warehouse Inventory',
            ),
            Tab(
              icon: const Icon(Icons.local_shipping_outlined),
              text: isAr ? 'تحويل المخزون' : 'Stock Transfer',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWarehousesTab(warehousesAsync),
          _buildInventoryTab(warehousesAsync, inventoriesAsync, productState),
          _buildTransfersTab(warehousesAsync, transfersAsync, productState),
        ],
      ),
    );
  }

  // TAB 1: WAREHOUSES
  Widget _buildWarehousesTab(AsyncValue<List<WarehouseEntity>> warehousesAsync) {
    final isAr = context.isRtl;

    return warehousesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (warehouses) {
        final filtered = warehouses.where((w) {
          if (_warehouseQuery.isEmpty) return true;
          final q = _warehouseQuery.toLowerCase();
          return w.nameEn.toLowerCase().contains(q) || w.nameAr.contains(q);
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchWarehouseController,
                      decoration: InputDecoration(
                        hintText: isAr ? 'بحث عن مستودع...' : 'Search warehouse...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _showWarehouseFormDialog(context, null),
                    icon: const Icon(Icons.add),
                    label: Text(isAr ? 'إضافة مستودع' : 'Add Warehouse'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(isAr ? 'لا توجد مستودعات تطابق البحث' : 'No warehouses found'))
                  : ListView.builder(
                      itemCount: filtered.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final wh = filtered[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: wh.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                              child: Icon(Icons.store_outlined, color: wh.isActive ? Colors.green : Colors.grey),
                            ),
                            title: Text(
                              isAr ? wh.nameAr : wh.nameEn,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(isAr ? wh.locationAr : wh.locationEn),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: wh.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    wh.isActive 
                                        ? (isAr ? 'نشط' : 'Active') 
                                        : (isAr ? 'غير نشط' : 'Inactive'),
                                    style: TextStyle(
                                      color: wh.isActive ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                  onPressed: () => _showWarehouseFormDialog(context, wh),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _confirmDeleteWarehouse(context, wh),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // TAB 2: INVENTORY
  Widget _buildInventoryTab(
    AsyncValue<List<WarehouseEntity>> warehousesAsync,
    AsyncValue<List<WarehouseInventoryEntity>> inventoriesAsync,
    ProductListState productState,
  ) {
    final isAr = context.isRtl;

    return warehousesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (warehouses) {
        if (warehouses.isEmpty) {
          return Center(child: Text(isAr ? 'يرجى إضافة مستودع أولاً' : 'Please add a warehouse first'));
        }

        final selectedId = ref.watch(selectedWarehouseIdProvider) ?? warehouses.first.id;

        return inventoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (inventories) {
            // Filter inventory by selected warehouse
            final warehouseInventories = inventories.where((i) => i.warehouseId == selectedId).toList();

            // Match products
            final list = productState.products.where((p) {
              if (_inventoryQuery.isEmpty) return true;
              final q = _inventoryQuery.toLowerCase();
              return p.nameEn.toLowerCase().contains(q) || p.nameAr.contains(q);
            }).map((product) {
              final inv = warehouseInventories.firstWhere(
                (i) => i.productId == product.id,
                orElse: () => WarehouseInventoryEntity(
                  id: '',
                  warehouseId: selectedId,
                  productId: product.id,
                  quantity: 0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
              return _InventoryItem(product: product, quantity: inv.quantity);
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Dropdown select warehouse
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: selectedId,
                          decoration: InputDecoration(
                            labelText: isAr ? 'المستودع النشط' : 'Active Warehouse',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          items: warehouses.map((w) {
                            return DropdownMenuItem(
                              value: w.id,
                              child: Text(isAr ? w.nameAr : w.nameEn),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(selectedWarehouseIdProvider.notifier).state = val;
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Search field
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _searchInventoryController,
                          decoration: InputDecoration(
                            hintText: isAr ? 'بحث عن منتج في المستودع...' : 'Search product in warehouse...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: list.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            isAr ? item.product.nameAr : item.product.nameEn,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            isAr ? 'القسم: ${item.product.categoryId}' : 'Category: ${item.product.categoryId}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${item.quantity} ${item.product.weightUnitId}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.edit_note, color: Colors.indigo),
                                onPressed: () => _showAdjustQuantityDialog(context, selectedId, item.product, item.quantity),
                                tooltip: isAr ? 'تعديل المخزون' : 'Adjust Quantity',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // TAB 3: TRANSFERS HISTORY & INITIATE
  Widget _buildTransfersTab(
    AsyncValue<List<WarehouseEntity>> warehousesAsync,
    AsyncValue<List<StockTransferEntity>> transfersAsync,
    ProductListState productState,
  ) {
    final isAr = context.isRtl;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'سجل عمليات نقل المخزون' : 'Stock Transfer History',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  final whs = warehousesAsync.value ?? [];
                  if (whs.length < 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isAr ? 'تحتاج لمستودعين على الأقل لإجراء النقل' : 'You need at least 2 warehouses to transfer stock')),
                    );
                    return;
                  }
                  _showTransferDialog(context, whs, productState.products);
                },
                icon: const Icon(Icons.swap_horiz),
                label: Text(isAr ? 'تحويل مخزون جديد' : 'New Stock Transfer'),
              ),
            ],
          ),
        ),
        Expanded(
          child: transfersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (transfers) {
              if (transfers.isEmpty) {
                return Center(child: Text(isAr ? 'لا توجد تحويلات سابقة' : 'No transfer history found'));
              }

              final warehouses = warehousesAsync.value ?? [];

              return ListView.builder(
                itemCount: transfers.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final tr = transfers[index];
                  final fromWh = warehouses.firstWhere((w) => w.id == tr.fromWarehouseId, orElse: () => WarehouseEntity(id: tr.fromWarehouseId, nameAr: 'مصدر غير معروف', nameEn: 'Unknown Source', locationAr: '', locationEn: '', createdAt: DateTime.now(), updatedAt: DateTime.now()));
                  final toWh = warehouses.firstWhere((w) => w.id == tr.toWarehouseId, orElse: () => WarehouseEntity(id: tr.toWarehouseId, nameAr: 'هدف غير معروف', nameEn: 'Unknown Destination', locationAr: '', locationEn: '', createdAt: DateTime.now(), updatedAt: DateTime.now()));
                  final prod = productState.products.firstWhere((p) => p.id == tr.productId, orElse: () => ProductEntity(id: tr.productId, nameAr: 'منتج غير معروف', nameEn: 'Unknown Product', price: 0, weight: 0, weightUnitId: 'unit', categoryId: '', createdAt: DateTime.now(), updatedAt: DateTime.now()));

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isAr ? prod.nameAr : prod.nameEn,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(tr.transferDate),
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(isAr ? 'من المستودع' : 'From Warehouse', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text(isAr ? fromWh.nameAr : fromWh.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(isAr ? 'إلى المستودع' : 'To Warehouse', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text(isAr ? toWh.nameAr : toWh.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(isAr ? 'الكمية المنقولة: ' : 'Quantity Transferred: '),
                                  Text(
                                    '${tr.quantity} ${prod.weightUnitId}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isAr ? 'مكتمل' : tr.status,
                                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          if (tr.notes != null && tr.notes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              isAr ? 'ملاحظات: ${tr.notes}' : 'Notes: ${tr.notes}',
                              style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // DIALOG 1: ADD/EDIT WAREHOUSE FORM
  void _showWarehouseFormDialog(BuildContext context, WarehouseEntity? existing) {
    final isAr = context.isRtl;
    final nameArController = TextEditingController(text: existing?.nameAr ?? '');
    final nameEnController = TextEditingController(text: existing?.nameEn ?? '');
    final locationArController = TextEditingController(text: existing?.locationAr ?? '');
    final locationEnController = TextEditingController(text: existing?.locationEn ?? '');
    bool isActive = existing?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(existing == null 
                  ? (isAr ? 'إضافة مستودع جديد' : 'Add New Warehouse') 
                  : (isAr ? 'تعديل بيانات المستودع' : 'Edit Warehouse')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameEnController,
                      decoration: const InputDecoration(labelText: 'Name (EN)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameArController,
                      decoration: const InputDecoration(labelText: 'الاسم (بالعربية)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: locationEnController,
                      decoration: const InputDecoration(labelText: 'Location Description (EN)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: locationArController,
                      decoration: const InputDecoration(labelText: 'الوصف المكاني (بالعربية)'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isAr ? 'الحالة نشط' : 'Active Status'),
                        Switch(
                          value: isActive,
                          onChanged: (val) {
                            setState(() {
                              isActive = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isAr ? 'إلغاء' : 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameEnController.text.trim().isEmpty || nameArController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isAr ? 'الرجاء ملء حقول الأسماء' : 'Please fill out name fields')),
                      );
                      return;
                    }

                    final wh = WarehouseEntity(
                      id: existing?.id ?? '',
                      nameAr: nameArController.text.trim(),
                      nameEn: nameEnController.text.trim(),
                      locationAr: locationArController.text.trim(),
                      locationEn: locationEnController.text.trim(),
                      isActive: isActive,
                      createdAt: existing?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    final notifier = ref.read(warehouseNotifierProvider.notifier);
                    bool success;
                    if (existing == null) {
                      success = await notifier.createWarehouse(wh);
                    } else {
                      success = await notifier.updateWarehouse(wh);
                    }

                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isAr ? 'تم حفظ المستودع بنجاح' : 'Warehouse saved successfully')),
                      );
                    }
                  },
                  child: Text(isAr ? 'حفظ' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // DIALOG 2: ADJUST WAREHOUSE INVENTORY QUANTITY
  void _showAdjustQuantityDialog(
    BuildContext context,
    String warehouseId,
    ProductEntity product,
    int currentQty,
  ) {
    final isAr = context.isRtl;
    final qtyController = TextEditingController(text: currentQty.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isAr ? 'تعديل كمية المخزون' : 'Adjust Inventory Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? product.nameAr : product.nameEn,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isAr ? 'الكمية الجديدة' : 'New Quantity',
                  suffixText: product.weightUnitId,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final input = int.tryParse(qtyController.text.trim());
                if (input == null || input < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isAr ? 'الرجاء إدخال رقم صحيح أكبر أو يساوي الصفر' : 'Please enter a valid quantity >= 0')),
                  );
                  return;
                }

                final success = await ref
                    .read(warehouseNotifierProvider.notifier)
                    .updateInventory(warehouseId, product.id, input);

                if (success && context.mounted) {
                  // Invalidate product notifier to refresh global stock list
                  ref.invalidate(productListProvider);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isAr ? 'تم تعديل المخزون بنجاح' : 'Stock adjusted successfully')),
                  );
                }
              },
              child: Text(isAr ? 'تحديث' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  // DIALOG 3: NEW STOCK TRANSFER FORM
  void _showTransferDialog(
    BuildContext context,
    List<WarehouseEntity> warehouses,
    List<ProductEntity> products,
  ) {
    final isAr = context.isRtl;

    // Filter only active warehouses
    final activeWhs = warehouses.where((w) => w.isActive).toList();
    if (activeWhs.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAr ? 'تحتاج إلى مستودعين نشطين على الأقل للتحويل' : 'You need at least 2 active warehouses to transfer stock')),
      );
      return;
    }

    String fromWhId = activeWhs.first.id;
    String toWhId = activeWhs[1].id;
    String prodId = products.isNotEmpty ? products.first.id : '';

    final qtyController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Find current stock of selected product in selected source warehouse
            final allInventories = ref.read(warehouseInventoriesStreamProvider).value ?? [];
            final currentSourceInv = allInventories.firstWhere(
              (i) => i.warehouseId == fromWhId && i.productId == prodId,
              orElse: () => WarehouseInventoryEntity(id: '', warehouseId: fromWhId, productId: prodId, quantity: 0, createdAt: DateTime.now(), updatedAt: DateTime.now()),
            );
            final sourceProd = products.firstWhere((p) => p.id == prodId, orElse: () => ProductEntity(id: prodId, nameAr: '', nameEn: '', price: 0, weight: 0, weightUnitId: '', categoryId: '', createdAt: DateTime.now(), updatedAt: DateTime.now()));

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isAr ? 'تحويل مخزون جديد بين المستودعات' : 'New Stock Transfer'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // From Warehouse
                    DropdownButtonFormField<String>(
                      value: fromWhId,
                      decoration: InputDecoration(labelText: isAr ? 'المستودع المصدر' : 'Source Warehouse'),
                      items: activeWhs.map((w) {
                        return DropdownMenuItem(value: w.id, child: Text(isAr ? w.nameAr : w.nameEn));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            fromWhId = val;
                            if (toWhId == fromWhId) {
                              toWhId = activeWhs.firstWhere((w) => w.id != fromWhId).id;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // To Warehouse
                    DropdownButtonFormField<String>(
                      value: toWhId,
                      decoration: InputDecoration(labelText: isAr ? 'المستودع الهدف' : 'Destination Warehouse'),
                      items: activeWhs.where((w) => w.id != fromWhId).map((w) {
                        return DropdownMenuItem(value: w.id, child: Text(isAr ? w.nameAr : w.nameEn));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            toWhId = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // Product Selection
                    DropdownButtonFormField<String>(
                      value: prodId,
                      decoration: InputDecoration(labelText: isAr ? 'المنتج المراد نقله' : 'Product to Transfer'),
                      items: products.map((p) {
                        return DropdownMenuItem(value: p.id, child: Text(isAr ? p.nameAr : p.nameEn));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            prodId = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    // Stock display
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAr 
                            ? 'المخزون المتاح في المصدر: ${currentSourceInv.quantity} ${sourceProd.weightUnitId}' 
                            : 'Available stock in source: ${currentSourceInv.quantity} ${sourceProd.weightUnitId}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quantity
                    TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: isAr ? 'الكمية المنقولة' : 'Quantity to Transfer',
                        suffixText: sourceProd.weightUnitId,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Notes
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(labelText: isAr ? 'ملاحظات اختيارية' : 'Optional Notes'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isAr ? 'إلغاء' : 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final qty = int.tryParse(qtyController.text.trim());
                    if (qty == null || qty <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isAr ? 'الرجاء إدخال كمية صحيحة أكبر من الصفر' : 'Please enter a valid quantity > 0')),
                      );
                      return;
                    }

                    if (qty > currentSourceInv.quantity) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isAr ? 'الكمية المطلوبة أكبر من المخزون المتاح' : 'Quantity exceeds available stock in source')),
                      );
                      return;
                    }

                    final success = await ref
                        .read(warehouseNotifierProvider.notifier)
                        .transferStock(
                          fromWarehouseId: fromWhId,
                          toWarehouseId: toWhId,
                          productId: prodId,
                          quantity: qty,
                          notes: notesController.text.trim(),
                        );

                    if (success && context.mounted) {
                      ref.invalidate(productListProvider);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isAr ? 'تم تحويل المخزون بنجاح' : 'Stock transfer completed successfully')),
                      );
                    }
                  },
                  child: Text(isAr ? 'تحويل' : 'Transfer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // DIALOG 4: DELETE CONFIRMATION
  void _confirmDeleteWarehouse(BuildContext context, WarehouseEntity wh) {
    final isAr = context.isRtl;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isAr ? 'حذف المستودع؟' : 'Delete Warehouse?'),
          content: Text(isAr
              ? 'هل أنت متأكد من حذف مستودع "${wh.nameAr}"؟ هذا سيحذف سجلات المخزون التابعة له أيضاً.'
              : 'Are you sure you want to delete "${wh.nameEn}"? This will clear all its warehouse stock inventories as well.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                final success = await ref
                    .read(warehouseNotifierProvider.notifier)
                    .deleteWarehouse(wh.id);
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isAr ? 'تم حذف المستودع' : 'Warehouse deleted')),
                  );
                }
              },
              child: Text(isAr ? 'حذف' : 'Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _InventoryItem {
  final ProductEntity product;
  final int quantity;
  _InventoryItem({required this.product, required this.quantity});
}
