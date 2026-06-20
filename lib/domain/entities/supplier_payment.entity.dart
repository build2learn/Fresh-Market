import 'package:equatable/equatable.dart';

class SupplierPaymentEntity extends Equatable {
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

  const SupplierPaymentEntity({
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

  @override
  List<Object?> get props => [
        id,
        supplierId,
        supplierName,
        amount,
        paymentDate,
        paymentMethod,
        referenceNumber,
        notes,
        createdAt,
        updatedAt,
      ];

  SupplierPaymentEntity copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? referenceNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupplierPaymentEntity(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
