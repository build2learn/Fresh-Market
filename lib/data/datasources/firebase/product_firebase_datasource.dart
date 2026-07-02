import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Future<void> adjustStock(String productId, int newQuantity, {String? reasonEn, String? reasonAr});
  Future<void> receiveStock(String productId, int quantityToAdd, {String? reasonEn, String? reasonAr});
}

class ProductFirebaseDataSourceImpl implements ProductFirebaseDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  ProductFirebaseDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _storage = storage,
        _auth = auth;

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
      return ProductDto.fromMap(data, docRef.id);
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
      return ProductDto.fromMap(data, product.id);
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

  @override
  Future<void> adjustStock(String productId, int newQuantity, {String? reasonEn, String? reasonAr}) async {
    if (newQuantity < 0) {
      throw const FirestoreException(message: 'Stock quantity cannot be negative');
    }
    try {
      final docRef = _collection.doc(productId);

      await _firestore.runTransaction((transaction) async {
        final productSnap = await transaction.get(docRef);
        if (!productSnap.exists) {
          throw const FirestoreException(message: 'Product not found');
        }
        final data = productSnap.data()!;
        final nameAr = data['nameAr'] as String? ?? '';
        final nameEn = data['nameEn'] as String? ?? '';
        final curStock = data['currentStock'] as int? ?? data['stockQuantity'] as int? ?? 50;
        final resStock = data['reservedStock'] as int? ?? 0;

        final newAvailable = newQuantity - resStock;
        if (newAvailable < 0) {
          throw FirestoreException(
            message: 'Cannot set stock to $newQuantity: $resStock units are currently reserved',
          );
        }

        transaction.update(docRef, {
          'currentStock': newQuantity,
          'availableStock': newAvailable,
          'stockQuantity': newAvailable, // legacy sync
          FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
        });

        // Log movement to stock_history
        final historyRef = _firestore.collection('stock_history').doc();
        transaction.set(historyRef, {
          'id': historyRef.id,
          'productId': productId,
          'productNameAr': nameAr,
          'productNameEn': nameEn,
          'type': 'adjustment',
          'quantityChanged': newQuantity - curStock,
          'previousStock': curStock,
          'newStock': newQuantity,
          'reasonAr': reasonAr ?? 'تعديل المخزون بواسطة المسؤول',
          'reasonEn': reasonEn ?? 'Stock adjusted by admin',
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': _auth.currentUser?.uid ?? 'admin',
        });
      });
    } on FirestoreException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to adjust stock',
        code: e.code,
      );
    }
  }

  @override
  Future<void> receiveStock(String productId, int quantityToAdd, {String? reasonEn, String? reasonAr}) async {
    if (quantityToAdd <= 0) {
      throw const FirestoreException(message: 'Quantity to receive must be greater than zero');
    }
    try {
      final docRef = _collection.doc(productId);

      await _firestore.runTransaction((transaction) async {
        final productSnap = await transaction.get(docRef);
        if (!productSnap.exists) {
          throw const FirestoreException(message: 'Product not found');
        }
        final data = productSnap.data()!;
        final nameAr = data['nameAr'] as String? ?? '';
        final nameEn = data['nameEn'] as String? ?? '';
        final curStock = data['currentStock'] as int? ?? data['stockQuantity'] as int? ?? 50;
        final resStock = data['reservedStock'] as int? ?? 0;
        final avStock = data['availableStock'] as int? ?? data['stockQuantity'] as int? ?? (curStock - resStock);

        final newCurrent = curStock + quantityToAdd;
        final newAvailable = avStock + quantityToAdd;

        transaction.update(docRef, {
          'currentStock': newCurrent,
          'availableStock': newAvailable,
          'stockQuantity': newAvailable, // legacy sync
          FirestoreConstants.updatedAt: FieldValue.serverTimestamp(),
        });

        // Log movement to stock_history
        final historyRef = _firestore.collection('stock_history').doc();
        transaction.set(historyRef, {
          'id': historyRef.id,
          'productId': productId,
          'productNameAr': nameAr,
          'productNameEn': nameEn,
          'type': 'receipt',
          'quantityChanged': quantityToAdd,
          'previousStock': curStock,
          'newStock': newCurrent,
          'reasonAr': reasonAr ?? 'استلام مخزون جديد بواسطة المسؤول',
          'reasonEn': reasonEn ?? 'Stock received by admin',
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': _auth.currentUser?.uid ?? 'admin',
        });
      });
    } on FirestoreException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to receive stock',
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
