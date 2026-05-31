import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/product.dto.dart';

abstract interface class ProductFirebaseDataSource {
  Future<List<ProductDto>> getProducts({int limit = 20, dynamic lastDoc, String? categoryId});
  Future<ProductDto?> getProduct(String id);
  Future<List<ProductDto>> getFeaturedProducts({int limit = 20});
  Stream<List<ProductDto>> watchProducts({int limit = 20});
  Stream<List<ProductDto>> watchFeaturedProducts({int limit = 20});
  Future<ProductDto> createProduct(ProductDto product, {String? imagePath});
  Future<ProductDto> updateProduct(ProductDto product, {String? imagePath});
  Future<void> deleteProduct(String productId);
  Future<void> toggleFeatured(String productId, bool isFeatured);
  Future<void> toggleAvailability(String productId, bool isAvailable);
}

class ProductFirebaseDataSourceImpl implements ProductFirebaseDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProductFirebaseDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.products);

  String get _productsImagesPath => 'products/images';

  @override
  Future<List<ProductDto>> getProducts({
    int limit = 20,
    dynamic lastDoc,
    String? categoryId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _collection
          .orderBy(FirestoreConstants.createdAt, descending: true)
          .limit(limit);
      if (categoryId != null) {
        query = _collection
            .where('categoryId', isEqualTo: categoryId)
            .orderBy(FirestoreConstants.createdAt, descending: true)
            .limit(limit);
      }
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc as DocumentSnapshot);
      }
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ProductDto.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to fetch products',
        code: e.code,
      );
    }
  }

  @override
  Future<ProductDto?> getProduct(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) return null;
      return ProductDto.fromMap(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to fetch product',
        code: e.code,
      );
    }
  }

  @override
  Future<List<ProductDto>> getFeaturedProducts({int limit = 20}) async {
    try {
      final snapshot = await _collection
          .where(FirestoreConstants.isFeatured, isEqualTo: true)
          .where(FirestoreConstants.isAvailable, isEqualTo: true)
          .orderBy(FirestoreConstants.createdAt, descending: true)
          .limit(limit)
          .get();
      return snapshot.docs
          .map((doc) => ProductDto.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to fetch featured products',
        code: e.code,
      );
    }
  }

  @override
  Stream<List<ProductDto>> watchProducts({int limit = 20}) {
    return _collection
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductDto.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<List<ProductDto>> watchFeaturedProducts({int limit = 20}) {
    return _collection
        .where(FirestoreConstants.isFeatured, isEqualTo: true)
        .where(FirestoreConstants.isAvailable, isEqualTo: true)
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductDto.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<ProductDto> createProduct(ProductDto product, {String? imagePath}) async {
    try {
      String? imageUrl = product.imageUrl;
      String? imageThumbUrl = product.imageThumbUrl;
      if (imagePath != null) {
        imageUrl = await _uploadImage(imagePath, _productsImagesPath);
        imageThumbUrl = imageUrl;
      }
      final now = DateTime.now();
      final data = product.copyWith(
        imageUrl: imageUrl,
        imageThumbUrl: imageThumbUrl,
        createdAt: now,
        updatedAt: now,
      ).toMap();
      final docRef = _collection.doc(product.id);
      await docRef.set(data);
      final createdDoc = await docRef.get();
      return ProductDto.fromMap(createdDoc.data()!, createdDoc.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to create product',
        code: e.code,
      );
    }
  }

  @override
  Future<ProductDto> updateProduct(ProductDto product, {String? imagePath}) async {
    try {
      String? imageUrl = product.imageUrl;
      String? imageThumbUrl = product.imageThumbUrl;
      if (imagePath != null) {
        if (product.imageUrl != null) {
          await _deleteImage(product.imageUrl!);
        }
        imageUrl = await _uploadImage(imagePath, _productsImagesPath);
        imageThumbUrl = imageUrl;
      }
      final now = DateTime.now();
      final data = product.copyWith(
        imageUrl: imageUrl,
        imageThumbUrl: imageThumbUrl,
        updatedAt: now,
      ).toMap();
      await _collection.doc(product.id).update(data);
      final updatedDoc = await _collection.doc(product.id).get();
      return ProductDto.fromMap(updatedDoc.data()!, updatedDoc.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to update product',
        code: e.code,
      );
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      final doc = await _collection.doc(productId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data?['imageUrl'] != null) {
          await _deleteImage(data!['imageUrl'] as String);
        }
      }
      await _collection.doc(productId).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to delete product',
        code: e.code,
      );
    }
  }

  @override
  Future<void> toggleFeatured(String productId, bool isFeatured) async {
    try {
      await _collection.doc(productId).update({
        FirestoreConstants.isFeatured: isFeatured,
        FirestoreConstants.updatedAt: DateTime.now(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to toggle featured',
        code: e.code,
      );
    }
  }

  @override
  Future<void> toggleAvailability(String productId, bool isAvailable) async {
    try {
      await _collection.doc(productId).update({
        FirestoreConstants.isAvailable: isAvailable,
        FirestoreConstants.updatedAt: DateTime.now(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to toggle availability',
        code: e.code,
      );
    }
  }

  Future<String> _uploadImage(String filePath, String storagePath) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref('$storagePath/$fileName');
    final file = File(filePath);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (_) {}
  }
}
