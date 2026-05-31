import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/category.dto.dart';

abstract interface class CategoryFirebaseDataSource {
  Future<List<CategoryDto>> getCategories({int limit});
  Future<List<CategoryDto>> getVisibleCategories({int limit});
  Future<List<CategoryDto>> getDeletedCategories({int limit});
  Stream<List<CategoryDto>> watchCategories({int limit});
  Future<CategoryDto> createCategory(CategoryDto category);
  Future<CategoryDto> updateCategory(CategoryDto category);
  Future<void> toggleVisibility(String categoryId, bool isVisible);
  Future<void> reorderCategories(List<String> categoryIds);
  Future<void> softDeleteCategory(String categoryId);
  Future<void> restoreCategory(String categoryId);
}

class CategoryFirebaseDataSourceImpl implements CategoryFirebaseDataSource {
  final FirebaseFirestore _firestore;

  CategoryFirebaseDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.categories);

  @override
  Future<List<CategoryDto>> getCategories({int limit = 100}) async {
    try {
      Query<Map<String, dynamic>> query = _collection
          .where(FirestoreConstants.isDeleted, isEqualTo: false)
          .orderBy(FirestoreConstants.sortOrder)
          .limit(limit);
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CategoryDto.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to fetch categories',
        code: e.code,
      );
    }
  }

  @override
  Future<List<CategoryDto>> getVisibleCategories({int limit = 100}) async {
    try {
      final snapshot = await _collection
          .where(FirestoreConstants.isVisible, isEqualTo: true)
          .where(FirestoreConstants.isDeleted, isEqualTo: false)
          .orderBy(FirestoreConstants.sortOrder)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => CategoryDto.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to fetch visible categories',
        code: e.code,
      );
    }
  }

  @override
  Future<List<CategoryDto>> getDeletedCategories({int limit = 100}) async {
    try {
      final snapshot = await _collection
          .where(FirestoreConstants.isDeleted, isEqualTo: true)
          .orderBy(FirestoreConstants.updatedAt, descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => CategoryDto.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to fetch deleted categories',
        code: e.code,
      );
    }
  }

  @override
  Stream<List<CategoryDto>> watchCategories({int limit = 100}) {
    return _collection
        .where(FirestoreConstants.isDeleted, isEqualTo: false)
        .orderBy(FirestoreConstants.sortOrder)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryDto.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<CategoryDto> createCategory(CategoryDto category) async {
    try {
      final docRef = _collection.doc(category.id);
      final now = DateTime.now();
      await docRef.set(category.copyWith(
        createdAt: now,
        updatedAt: now,
      ).toMap());
      final createdDoc = await docRef.get();
      return CategoryDto.fromMap(createdDoc.data()!, createdDoc.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to create category',
        code: e.code,
      );
    }
  }

  @override
  Future<CategoryDto> updateCategory(CategoryDto category) async {
    try {
      final now = DateTime.now();
      final data = category.copyWith(updatedAt: now).toMap();
      await _collection.doc(category.id).update(data);
      final updatedDoc = await _collection.doc(category.id).get();
      return CategoryDto.fromMap(updatedDoc.data()!, updatedDoc.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to update category',
        code: e.code,
      );
    }
  }

  @override
  Future<void> toggleVisibility(String categoryId, bool isVisible) async {
    try {
      await _collection.doc(categoryId).update({
        FirestoreConstants.isVisible: isVisible,
        FirestoreConstants.updatedAt: DateTime.now(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to toggle visibility',
        code: e.code,
      );
    }
  }

  @override
  Future<void> reorderCategories(List<String> categoryIds) async {
    try {
      final batch = _firestore.batch();
      for (var i = 0; i < categoryIds.length; i++) {
        batch.update(
          _collection.doc(categoryIds[i]),
          {
            FirestoreConstants.sortOrder: i,
            FirestoreConstants.updatedAt: DateTime.now(),
          },
        );
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to reorder categories',
        code: e.code,
      );
    }
  }

  @override
  Future<void> softDeleteCategory(String categoryId) async {
    try {
      await _collection.doc(categoryId).update({
        FirestoreConstants.isDeleted: true,
        FirestoreConstants.isVisible: false,
        FirestoreConstants.updatedAt: DateTime.now(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to delete category',
        code: e.code,
      );
    }
  }

  @override
  Future<void> restoreCategory(String categoryId) async {
    try {
      await _collection.doc(categoryId).update({
        FirestoreConstants.isDeleted: false,
        FirestoreConstants.updatedAt: DateTime.now(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to restore category',
        code: e.code,
      );
    }
  }
}
