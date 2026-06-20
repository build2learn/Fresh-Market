import '../../core/constants/firestore_constants.dart';

class SupplierPaymentDto {
  final String id;
  final String supplierId;
  final String supplierName;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String referenceNumber;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupplierPaymentDto({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.referenceNumber,
    required this.notes,
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

  factory SupplierPaymentDto.fromMap(Map<String, dynamic> map, String documentId) {
    return SupplierPaymentDto(
      id: documentId,
      supplierId: map['supplierId'] as String? ?? '',
      supplierName: map['supplierName'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: _toDateTime(map['paymentDate']),
      paymentMethod: map['paymentMethod'] as String? ?? '',
      referenceNumber: map['referenceNumber'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdAt: _toDateTime(map[FirestoreConstants.createdAt]),
      updatedAt: _toDateTime(map[FirestoreConstants.updatedAt]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'supplierId': supplierId,
      'supplierName': supplierName,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'referenceNumber': referenceNumber,
      'notes': notes,
      FirestoreConstants.createdAt: createdAt.toIso8601String(),
      FirestoreConstants.updatedAt: updatedAt.toIso8601String(),
    };
  }
}
