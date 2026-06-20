enum UserRole {
  admin('admin'),
  manager('manager'),
  warehouse('warehouse'),
  delivery('delivery'),
  customerService('customerService'),
  customer('customer');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.customer,
    );
  }

  bool get isAdmin => this == UserRole.admin;
  bool get isCustomer => this == UserRole.customer;
  bool get isStaff => this != UserRole.customer;

  // Permissions
  bool get canManageProducts => this == UserRole.admin || this == UserRole.manager;
  bool get canManageOrders =>
      this == UserRole.admin ||
      this == UserRole.manager ||
      this == UserRole.warehouse ||
      this == UserRole.delivery ||
      this == UserRole.customerService;
  bool get canManageInventory =>
      this == UserRole.admin || this == UserRole.manager || this == UserRole.warehouse;
  bool get canManageReports => this == UserRole.admin || this == UserRole.manager;
  bool get canManageSettings => this == UserRole.admin;
}
