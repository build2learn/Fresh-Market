import '../../core/constants/firestore_constants.dart';

class SupplierDto {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupplierDto({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value == null) return DateTime.now();
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  factory SupplierDto.fromMap(Map<String, dynamic> map, String documentId) {
    return SupplierDto(
      id: documentId,
      name: map['name'] as String? ?? '',
      contactPerson: map['contactPerson'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: _toDateTime(map[FirestoreConstants.createdAt]),
      updatedAt: _toDateTime(map[FirestoreConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'balance': balance,
      FirestoreConstants.createdAt: createdAt.toIso8601String(),
      FirestoreConstants.updatedAt: updatedAt.toIso8601String(),
    };
  }
}
