import 'dart:async';
import '../../core/utils/result.dart';
import '../entities/supplier_payment.entity.dart';

abstract interface class SupplierPaymentRepository {
  Future<Result<List<SupplierPaymentEntity>>> getPayments({String? supplierId});
  Stream<List<SupplierPaymentEntity>> watchPayments({String? supplierId});
  Future<Result<SupplierPaymentEntity>> createPayment(SupplierPaymentEntity payment);
  Future<Result<void>> deletePayment(String paymentId);
}
