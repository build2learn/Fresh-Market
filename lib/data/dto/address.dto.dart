class AddressDto {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddressDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    this.notes,
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
      } catch (err) {
        return DateTime.now();
      }
    }
  }

  factory AddressDto.fromMap(Map<String, dynamic> map, String documentId) {
    return AddressDto(
      id: documentId,
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      notes: map['notes'] as String?,
      createdAt: _toDateTime(map['createdAt']),
      updatedAt: _toDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
