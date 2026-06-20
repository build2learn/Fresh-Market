import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/supplier_payment.entity.dart';
import '../../domain/repositories/supplier_payment_repository.dart';
import '../dto/supplier_payment.dto.dart';
import '../models/supplier_payment_model.dart';

class SupplierPaymentRepositoryImpl implements SupplierPaymentRepository {
  final FirebaseFirestore _firestore;

  SupplierPaymentRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _paymentsCol => _firestore.collection('supplier_payments');
  CollectionReference get _suppliersCol => _firestore.collection('suppliers');

  @override
  Future<Result<List<SupplierPaymentEntity>>> getPayments({String? supplierId}) async {
    try {
      Query query = _paymentsCol.orderBy(FirestoreConstants.createdAt, descending: true);
      if (supplierId != null && supplierId.isNotEmpty) {
        query = query.where('supplierId', isEqualTo: supplierId);
      }
      final snapshot = await query.get();
      final payments = snapshot.docs.map((doc) {
        final dto = SupplierPaymentDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return SupplierPaymentModel.fromDto(dto).toEntity();
      }).toList();
      return Success(payments);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<SupplierPaymentEntity>> watchPayments({String? supplierId}) {
    Query query = _paymentsCol.orderBy(FirestoreConstants.createdAt, descending: true);
    if (supplierId != null && supplierId.isNotEmpty) {
      query = query.where('supplierId', isEqualTo: supplierId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final dto = SupplierPaymentDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        return SupplierPaymentModel.fromDto(dto).toEntity();
      }).toList();
    });
  }

  @override
  Future<Result<SupplierPaymentEntity>> createPayment(SupplierPaymentEntity payment) async {
    try {
      final batch = _firestore.batch();
      
      final docRef = _paymentsCol.doc();
      final paymentModel = SupplierPaymentModel.fromEntity(payment.copyWith(id: docRef.id));
      
      batch.set(
        docRef,
        paymentModel.toMap()
          ..[FirestoreConstants.createdAt] = FieldValue.serverTimestamp()
          ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp(),
      );

      final supplierRef = _suppliersCol.doc(payment.supplierId);
      batch.update(supplierRef, {
        'balance': FieldValue.increment(-payment.amount),
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      });

      await batch.commit();
      
      // Fetch completed document to get server timestamps for completeness
      final doc = await docRef.get();
      final dto = SupplierPaymentDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      return Success(SupplierPaymentModel.fromDto(dto).toEntity());
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deletePayment(String paymentId) async {
    try {
      final paymentSnapshot = await _paymentsCol.doc(paymentId).get();
      if (!paymentSnapshot.exists) {
        return Failure(FirestoreException(message: 'Payment not found'));
      }
      
      final paymentMap = paymentSnapshot.data() as Map<String, dynamic>;
      final supplierId = paymentMap['supplierId'] as String;
      final amount = (paymentMap['amount'] as num).toDouble();
      
      final batch = _firestore.batch();
      
      // Delete the payment document
      batch.delete(_paymentsCol.doc(paymentId));
      
      // Increment the supplier balance back by payment amount
      final supplierRef = _suppliersCol.doc(supplierId);
      batch.update(supplierRef, {
        'balance': FieldValue.increment(amount),
        FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
      });
      
      await batch.commit();
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
