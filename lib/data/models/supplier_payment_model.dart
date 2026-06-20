import '../dto/supplier_payment.dto.dart';
import '../../domain/entities/supplier_payment.entity.dart';

class SupplierPaymentModel extends SupplierPaymentDto {
  const SupplierPaymentModel({
    required super.id,
    required super.supplierId,
    required super.supplierName,
    required super.amount,
    required super.paymentDate,
    required super.paymentMethod,
    required super.referenceNumber,
    required super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory SupplierPaymentModel.fromDto(SupplierPaymentDto dto) {
    return SupplierPaymentModel(
      id: dto.id,
      supplierId: dto.supplierId,
      supplierName: dto.supplierName,
      amount: dto.amount,
      paymentDate: dto.paymentDate,
      paymentMethod: dto.paymentMethod,
      referenceNumber: dto.referenceNumber,
      notes: dto.notes,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  factory SupplierPaymentModel.fromEntity(SupplierPaymentEntity entity) {
    return SupplierPaymentModel(
      id: entity.id,
      supplierId: entity.supplierId,
      supplierName: entity.supplierName,
      amount: entity.amount,
      paymentDate: entity.paymentDate,
      paymentMethod: entity.paymentMethod,
      referenceNumber: entity.referenceNumber,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  SupplierPaymentEntity toEntity() {
    return SupplierPaymentEntity(
      id: id,
      supplierId: supplierId,
      supplierName: supplierName,
      amount: amount,
      paymentDate: paymentDate,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
