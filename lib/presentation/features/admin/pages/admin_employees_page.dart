import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/enums/user_role.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';

class AdminEmployeesPage extends ConsumerStatefulWidget {
  const AdminEmployeesPage({super.key});

  @override
  ConsumerState<AdminEmployeesPage> createState() => _AdminEmployeesPageState();
}

class _AdminEmployeesPageState extends ConsumerState<AdminEmployeesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRoleFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
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
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'إدارة الموظفين والصلاحيات' : 'Employee Directory & Permissions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.people_outline),
              text: isAr ? 'دليل الموظفين' : 'Staff Directory',
            ),
            Tab(
              icon: const Icon(Icons.security_outlined),
              text: isAr ? 'مصفوفة الصلاحيات' : 'Role Permissions',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDirectoryTab(),
          _buildPermissionsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEmployeeDialog(),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: Text(isAr ? 'إضافة موظف' : 'Add Employee'),
      ),
    );
  }

  Widget _buildDirectoryTab() {
    final isAr = context.isRtl;

    final mockEmployees = [
      _EmployeeMock('1', 'Amr Hassan', isAr ? 'عمرو حسن' : 'Amr Hassan', 'amr.hassan@freshmarket.com', '0122345678', UserRole.delivery, true),
      _EmployeeMock('2', 'Karim Ali', isAr ? 'كريم علي' : 'Karim Ali', 'karim.ali@freshmarket.com', '0100987654', UserRole.delivery, true),
      _EmployeeMock('3', 'Sherif Kamel', isAr ? 'شريف كامل' : 'Sherif Kamel', 'sherif.kamel@freshmarket.com', '0111223344', UserRole.warehouse, true),
      _EmployeeMock('4', 'Nour El-Din', isAr ? 'نور الدين' : 'Nour El-Din', 'nour.eldin@freshmarket.com', '0155556677', UserRole.warehouse, true),
      _EmployeeMock('5', 'Fatma Omar', isAr ? 'فاطمة عمر' : 'Fatma Omar', 'fatma.omar@freshmarket.com', '0109988776', UserRole.customerService, true),
      _EmployeeMock('6', 'Tamer Refaat', isAr ? 'تامر رفعت' : 'Tamer Refaat', 'tamer.refaat@freshmarket.com', '0123344556', UserRole.manager, true),
      _EmployeeMock('7', 'Abdelrahman M.', isAr ? 'عبدالرحمن محمد' : 'Abdelrahman M.', 'admin@freshmarket.com', '0100100200', UserRole.admin, true),
    ];

    final filtered = mockEmployees.where((emp) {
      if (_selectedRoleFilter != 'all' && emp.role.value != _selectedRoleFilter) return false;
      if (_searchQuery.isEmpty) return true;
      final name = emp.nameEn.toLowerCase();
      final nameAr = emp.nameAr.toLowerCase();
      final email = emp.email.toLowerCase();
      final phone = emp.phone;
      return name.contains(_searchQuery) ||
          nameAr.contains(_searchQuery) ||
          email.contains(_searchQuery) ||
          phone.contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isAr ? 'بحث باسم الموظف، البريد، أو الهاتف...' : 'Search by name, email, or phone...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRoleFilter,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(isAr ? 'الكل' : 'All Roles')),
                    ...UserRole.values.where((r) => r != UserRole.customer).map((r) {
                      return DropdownMenuItem(
                        value: r.value,
                        child: Text(r.value.toUpperCase()),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRoleFilter = val;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final emp = filtered[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: context.colorScheme.primaryContainer,
                    child: Text(
                      emp.nameEn[0].toUpperCase(),
                      style: TextStyle(
                        color: context.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          isAr ? emp.nameAr : emp.nameEn,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Text(
                          emp.role.value.toUpperCase(),
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(emp.email, style: const TextStyle(fontSize: 12)),
                      Text(emp.phone, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: emp.isActive,
                        onChanged: (val) {
                          // Mock status change
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isAr ? 'تم تغيير حالة النشاط' : 'Employee status updated')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showEditEmployeeRoleDialog(emp),
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
  }

  Widget _buildPermissionsTab() {
    final isAr = context.isRtl;

    // We can show a permission breakdown matrix for all roles:
    final roles = UserRole.values.where((r) => r != UserRole.customer).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'مصفوفة صلاحيات النظام الافتراضية' : 'System Role Permission Matrix',
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                isAr 
                    ? 'تعرض هذه المصفوفة الصلاحيات الممنوحة تلقائياً لكل دور وظيفي في النظام.'
                    : 'This matrix illustrates the actions granted by default to each system role.',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  defaultColumnWidth: const FixedColumnWidth(150),
                  border: TableBorder.all(color: Colors.grey.shade300, width: 1, borderRadius: BorderRadius.circular(8)),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: context.colorScheme.surfaceVariant.withOpacity(0.4)),
                      children: [
                        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(isAr ? 'الصلاحية / الدور' : 'Permission / Role', style: const TextStyle(fontWeight: FontWeight.bold)))),
                        ...roles.map((r) => TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(r.value.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)))),
                      ],
                    ),
                    _buildPermissionRow('Manage Products', (r) => r.canManageProducts),
                    _buildPermissionRow('Manage Orders', (r) => r.canManageOrders),
                    _buildPermissionRow('Manage Inventory', (r) => r.canManageInventory),
                    _buildPermissionRow('View Reports', (r) => r.canManageReports),
                    _buildPermissionRow('System Settings', (r) => r.canManageSettings),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildPermissionRow(String permissionLabel, bool Function(UserRole) checkFunc) {
    final roles = UserRole.values.where((r) => r != UserRole.customer).toList();
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(permissionLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ),
        ...roles.map((r) {
          final hasPerm = checkFunc(r);
          return TableCell(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  hasPerm ? Icons.check_circle : Icons.cancel,
                  color: hasPerm ? Colors.green : Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showAddEmployeeDialog() {
    final isAr = context.isRtl;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? 'إضافة موظف جديد' : 'Register New Employee'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: isAr ? 'الاسم بالإنجليزية' : 'Name (English)'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: isAr ? 'الاسم بالعربية' : 'Name (Arabic)'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: isAr ? 'البريد الإلكتروني' : 'Email Address'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: isAr ? 'رقم الهاتف' : 'Phone Number'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  decoration: InputDecoration(labelText: isAr ? 'الدور الوظيفي' : 'System Role'),
                  items: UserRole.values
                      .where((r) => r != UserRole.customer)
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role.value.toUpperCase()),
                          ),)
                      .toList(),
                  onChanged: (val) {},
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isAr ? 'تم تسجيل الموظف وإرسال رابط التفعيل' : 'Employee registered successfully!')),
              );
            },
            child: Text(isAr ? 'إضافة' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showEditEmployeeRoleDialog(_EmployeeMock emp) {
    final isAr = context.isRtl;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? 'تعديل الصلاحية / الدور للموظف' : 'Modify Employee Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${isAr ? 'الاسم:' : 'Name:'} ${isAr ? emp.nameAr : emp.nameEn}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<UserRole>(
              value: emp.role,
              decoration: InputDecoration(labelText: isAr ? 'الدور الوظيفي الجديد' : 'New System Role'),
              items: UserRole.values
                  .where((r) => r != UserRole.customer)
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.value.toUpperCase()),
                      ),)
                  .toList(),
              onChanged: (val) {},
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isAr ? 'تم تحديث الدور الوظيفي بنجاح' : 'System role updated successfully!')),
              );
            },
            child: Text(isAr ? 'حفظ التعديلات' : 'Save Changes'),
          ),
        ],
      ),
    );
  }
}

class _EmployeeMock {
  final String id;
  final String nameEn;
  final String nameAr;
  final String email;
  final String phone;
  final UserRole role;
  final bool isActive;

  _EmployeeMock(this.id, this.nameEn, this.nameAr, this.email, this.phone, this.role, this.isActive);
}
