import 'dart:async';
import '../../core/utils/result.dart';
import '../entities/supplier.entity.dart';

abstract interface class SupplierRepository {
  Future<Result<List<SupplierEntity>>> getSuppliers();
  Stream<List<SupplierEntity>> watchSuppliers();
  Future<Result<SupplierEntity>> createSupplier(SupplierEntity supplier);
  Future<Result<SupplierEntity>> updateSupplier(SupplierEntity supplier);
  Future<Result<void>> deleteSupplier(String supplierId);
}
