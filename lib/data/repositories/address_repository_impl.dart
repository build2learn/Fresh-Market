import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/address.entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../dto/address.dto.dart';
import '../models/address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final FirebaseFirestore _firestore;

  AddressRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _addressesCol => _firestore.collection(FirestoreConstants.addresses);

  @override
  Future<Result<List<AddressEntity>>> getAddresses(String userId) async {
    try {
      final snapshot = await _addressesCol
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      final list = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AddressModel.fromDto(AddressDto.fromMap(data, doc.id));
      }).toList();
      return Success(list);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<AddressEntity>> watchAddresses(String userId) {
    return _addressesCol
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AddressModel.fromDto(AddressDto.fromMap(data, doc.id));
      }).toList();
    });
  }

  @override
  Future<Result<AddressEntity>> createAddress(AddressEntity address) async {
    try {
      final docRef = _addressesCol.doc();
      final finalAddress = address.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final dto = AddressModel.fromEntity(finalAddress);
      
      final data = dto.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await docRef.set(data);
      return Success(finalAddress);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<AddressEntity>> updateAddress(AddressEntity address) async {
    try {
      final docRef = _addressesCol.doc(address.id);
      final finalAddress = address.copyWith(updatedAt: DateTime.now());
      final dto = AddressModel.fromEntity(finalAddress);

      final data = dto.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.update(data);
      return Success(finalAddress);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAddress(String id) async {
    try {
      await _addressesCol.doc(id).delete();
      return const Success(null);
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
