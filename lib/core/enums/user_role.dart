enum UserRole {
  admin('admin'),
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
}
