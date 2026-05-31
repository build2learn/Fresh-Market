import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/weight_unit.dto.dart';

abstract interface class WeightUnitFirebaseDataSource {
  Future<List<WeightUnitDto>> getWeightUnits();
  Future<WeightUnitDto> createWeightUnit(WeightUnitDto unit);
  Future<WeightUnitDto> updateWeightUnit(WeightUnitDto unit);
  Future<void> deleteWeightUnit(String id);
}

class WeightUnitFirebaseDataSourceImpl implements WeightUnitFirebaseDataSource {
  final FirebaseFirestore _firestore;

  WeightUnitFirebaseDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.weightUnits);

  @override
  Future<List<WeightUnitDto>> getWeightUnits() async {
    try {
      final snapshot = await _collection
          .orderBy(FirestoreConstants.sortOrder)
          .get();
      return snapshot.docs
          .map((doc) => WeightUnitDto.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to fetch weight units',
        code: e.code,
      );
    }
  }

  @override
  Future<WeightUnitDto> createWeightUnit(WeightUnitDto unit) async {
    try {
      final now = DateTime.now();
      final data = unit.copyWith(createdAt: now, updatedAt: now).toMap();
      final docRef = _collection.doc(unit.id);
      await docRef.set(data);
      final createdDoc = await docRef.get();
      return WeightUnitDto.fromMap(createdDoc.data()!, createdDoc.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to create weight unit',
        code: e.code,
      );
    }
  }

  @override
  Future<WeightUnitDto> updateWeightUnit(WeightUnitDto unit) async {
    try {
      final data = unit.copyWith(updatedAt: DateTime.now()).toMap();
      await _collection.doc(unit.id).update(data);
      final updatedDoc = await _collection.doc(unit.id).get();
      return WeightUnitDto.fromMap(updatedDoc.data()!, updatedDoc.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to update weight unit',
        code: e.code,
      );
    }
  }

  @override
  Future<void> deleteWeightUnit(String id) async {
    try {
      await _collection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to delete weight unit',
        code: e.code,
      );
    }
  }
}
