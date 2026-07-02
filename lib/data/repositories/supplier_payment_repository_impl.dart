import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/supplier_payment.entity.dart';
import '../../domain/repositories/supplier_payment_repository.dart';
import '../dto/supplier_payment.dto.dart';
import '../models/supplier_payment_model.dart';

class SupplierPaymentRepositoryImpl implements SupplierPaymentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SupplierPaymentRepositoryImpl({
    required FirebaseFirestore firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference get _paymentsCol => _firestore.collection('supplier_payments');
  CollectionReference get _suppliersCol => _firestore.collection('suppliers');

  String get _currentUserId => _auth.currentUser?.uid ?? 'system';
  String get _currentUserEmail => _auth.currentUser?.email ?? 'system@freshmarket.com';

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
    if (payment.amount <= 0) {
      return Failure(const FirestoreException(message: 'Payment amount must be greater than zero'));
    }
    try {
      final docRef = _paymentsCol.doc();
      final finalPayment = payment.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.runTransaction((transaction) async {
        // Read Phase: verify supplier existence
        final supplierRef = _suppliersCol.doc(payment.supplierId);
        final supplierSnap = await transaction.get(supplierRef);
        if (!supplierSnap.exists) {
          throw const FirestoreException(message: 'Supplier not found');
        }

        final paymentModel = SupplierPaymentModel.fromEntity(finalPayment);
        transaction.set(
          docRef,
          paymentModel.toMap()
            ..[FirestoreConstants.createdAt] = FieldValue.serverTimestamp()
            ..[FirestoreConstants.updatedAt] = FieldValue.serverTimestamp(),
        );

        transaction.update(supplierRef, {
          'balance': FieldValue.increment(-payment.amount),
          FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
        });

        // Audit Trail entry
        final logRef = _firestore.collection('audit_logs').doc();
        transaction.set(logRef, {
          'id': logRef.id,
          'userId': _currentUserId,
          'userEmail': _currentUserEmail,
          'action': 'Create Supplier Payment',
          'details': 'Recorded payment of ${payment.amount} EGP to supplier ${payment.supplierName} (Ref: ${payment.referenceNumber})',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      return Success(finalPayment);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deletePayment(String paymentId) async {
    try {
      final docRef = _paymentsCol.doc(paymentId);

      await _firestore.runTransaction((transaction) async {
        // Read Phase inside transaction to avoid race conditions
        final paymentSnapshot = await transaction.get(docRef);
        if (!paymentSnapshot.exists) {
          throw const FirestoreException(message: 'Payment not found');
        }

        final paymentMap = paymentSnapshot.data() as Map<String, dynamic>;
        final supplierId = paymentMap['supplierId'] as String? ?? '';
        final amount = (paymentMap['amount'] as num? ?? 0.0).toDouble();
        final supplierName = paymentMap['supplierName'] as String? ?? '';
        final refNum = paymentMap['referenceNumber'] as String? ?? '';

        // Delete the payment document
        transaction.delete(docRef);

        // Increment the supplier balance back by payment amount
        if (supplierId.isNotEmpty) {
          final supplierRef = _suppliersCol.doc(supplierId);
          transaction.update(supplierRef, {
            'balance': FieldValue.increment(amount),
            FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
          });
        }

        // Audit Trail entry
        final logRef = _firestore.collection('audit_logs').doc();
        transaction.set(logRef, {
          'id': logRef.id,
          'userId': _currentUserId,
          'userEmail': _currentUserEmail,
          'action': 'Delete Supplier Payment',
          'details': 'Deleted payment of $amount EGP to supplier $supplierName (Ref: $refNum)',
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
