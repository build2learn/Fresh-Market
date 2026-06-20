import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/supplier.entity.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../dto/supplier.dto.dart';
import '../models/supplier_model.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final FirebaseFirestore _firestore;

  SupplierRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _suppliersCol => _firestore.collection('suppliers');

  @override
  Future<Result<List<SupplierEntity>>> getSuppliers() async {
    try {
      final snapshot = await _suppliersCol.orderBy(FirestoreConstants.createdAt, descending: true).get();
      final suppliers = snapshot.docs.map((doc) {
        final dto = SupplierDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return SupplierModel.fromDto(dto).toEntity();
      }).toList();
      return Success(suppliers);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<SupplierEntity>> watchSuppliers() {
    return _suppliersCol
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final dto = SupplierDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return SupplierModel.fromDto(dto).toEntity();
      }).toList();
    });
  }

  @override
  Future<Result<SupplierEntity>> createSupplier(SupplierEntity supplier) async {
    try {
      final docRef = await _suppliersCol.add(
        SupplierModel.fromEntity(supplier).toMap()
          ..[FirestoreConstants.createdAt] = FieldValue.serverTimestamp()
          ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp(),
      );
      final doc = await docRef.get();
      final dto = SupplierDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      return Success(SupplierModel.fromDto(dto).toEntity());
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<SupplierEntity>> updateSupplier(SupplierEntity supplier) async {
    try {
      await _suppliersCol.doc(supplier.id).update(
        SupplierModel.fromEntity(supplier).toMap()
          ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp(),
      );
      return Success(supplier);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteSupplier(String supplierId) async {
    try {
      await _suppliersCol.doc(supplierId).delete();
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
