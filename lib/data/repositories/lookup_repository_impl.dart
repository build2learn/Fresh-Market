import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/lookup.entity.dart';
import '../../domain/repositories/lookup_repository.dart';
import '../dto/lookup.dto.dart';
import '../models/lookup_model.dart';

class LookupRepositoryImpl implements LookupRepository {
  final FirebaseFirestore _firestore;

  LookupRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('lookups');

  @override
  Future<Result<List<LookupEntity>>> getLookups(String lookupType) async {
    try {
      final snapshot = await _collection
          .where('lookupType', isEqualTo: lookupType)
          .orderBy('sortOrder')
          .get();
      final list = snapshot.docs
          .map((doc) => LookupModel.fromDto(LookupDto.fromMap(doc.data(), doc.id)).toEntity())
          .toList();
      return Success(list);
    } on FirebaseException catch (e) {
      return Failure(FirestoreException(message: e.message ?? 'Failed to fetch lookups', code: e.code));
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Stream<List<LookupEntity>> watchLookups(String lookupType) {
    return _collection
        .where('lookupType', isEqualTo: lookupType)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LookupModel.fromDto(LookupDto.fromMap(doc.data(), doc.id)).toEntity())
            .toList());
  }

  @override
  Future<Result<LookupEntity>> createLookup(LookupEntity lookup) async {
    try {
      final docRef = _collection.doc(lookup.id.toString());
      final now = DateTime.now();
      final dto = LookupModel.fromEntity(lookup.copyWith(
        createdAt: now,
        updatedAt: now,
      ));
      await docRef.set(dto.toMap());
      return Success(lookup.copyWith(createdAt: now, updatedAt: now));
    } on FirebaseException catch (e) {
      return Failure(FirestoreException(message: e.message ?? 'Failed to create lookup', code: e.code));
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<LookupEntity>> updateLookup(LookupEntity lookup) async {
    try {
      final docRef = _collection.doc(lookup.id.toString());
      final now = DateTime.now();
      final dto = LookupModel.fromEntity(lookup.copyWith(
        updatedAt: now,
      ));
      await docRef.update(dto.toMap());
      return Success(lookup.copyWith(updatedAt: now));
    } on FirebaseException catch (e) {
      return Failure(FirestoreException(message: e.message ?? 'Failed to update lookup', code: e.code));
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteLookup(int id) async {
    try {
      await _collection.doc(id.toString()).delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(FirestoreException(message: e.message ?? 'Failed to delete lookup', code: e.code));
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> reorderLookups(String lookupType, List<int> ids) async {
    try {
      final batch = _firestore.batch();
      for (var i = 0; i < ids.length; i++) {
        batch.update(
          _collection.doc(ids[i].toString()),
          {
            'sortOrder': i,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );
      }
      await batch.commit();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Failure(FirestoreException(message: e.message ?? 'Failed to reorder lookups', code: e.code));
    } catch (e) {
      return Failure(FirestoreException(message: e.toString()));
    }
  }
}
