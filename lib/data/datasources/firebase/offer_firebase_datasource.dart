import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../dto/offer.dto.dart';
import '../../dto/offer_product.dto.dart';

abstract interface class OfferFirebaseDataSource {
  Future<List<OfferDto>> getOffers();
  Future<List<OfferDto>> getActiveOffers();
  Future<OfferDto?> getOffer(String id);
  Future<List<OfferProductDto>> getOfferProducts(String offerId);
  Stream<List<OfferDto>> watchActiveOffers();
  Future<OfferDto> createOffer(OfferDto offer, {String? imagePath});
  Future<OfferDto> updateOffer(OfferDto offer, {String? imagePath});
  Future<void> deleteOffer(String offerId);
  Future<void> toggleActive(String offerId, bool isActive);
  Future<void> addOfferProduct(String offerId, String productId);
  Future<void> removeOfferProducts(String offerId);
}

class OfferFirebaseDataSourceImpl implements OfferFirebaseDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  OfferFirebaseDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.offers);

  CollectionReference<Map<String, dynamic>> _offerProductsCollection(String offerId) =>
      _firestore.collection('${FirestoreConstants.offers}/$offerId/${FirestoreConstants.offerProducts}');

  String get _offersImagesPath => 'offers/images';

  @override
  Future<List<OfferDto>> getOffers() async {
    try {
      final snapshot = await _collection
          .orderBy(FirestoreConstants.createdAt, descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OfferDto.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to fetch offers',
        code: e.code,
      );
    }
  }

  @override
  Future<List<OfferDto>> getActiveOffers() async {
    try {
      final snapshot = await _collection
          .where(FirestoreConstants.isActive, isEqualTo: true)
          .orderBy(FirestoreConstants.createdAt, descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OfferDto.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to fetch active offers',
        code: e.code,
      );
    }
  }

  @override
  Future<OfferDto?> getOffer(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) return null;
      return OfferDto.fromMap(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to fetch offer',
        code: e.code,
      );
    }
  }

  @override
  Future<List<OfferProductDto>> getOfferProducts(String offerId) async {
    try {
      final snapshot = await _offerProductsCollection(offerId)
          .orderBy(FirestoreConstants.createdAt, descending: true)
          .get();
      return snapshot.docs
          .map((doc) => OfferProductDto.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to fetch offer products',
        code: e.code,
      );
    }
  }

  @override
  Stream<List<OfferDto>> watchActiveOffers() {
    return _collection
        .where(FirestoreConstants.isActive, isEqualTo: true)
        .orderBy(FirestoreConstants.createdAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OfferDto.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<OfferDto> createOffer(OfferDto offer, {String? imagePath}) async {
    try {
      String? imageUrl = offer.imageUrl;
      if (imagePath != null) {
        imageUrl = await _uploadImage(imagePath, _offersImagesPath);
      }
      final now = DateTime.now();
      final data = offer.copyWith(
        imageUrl: imageUrl,
        createdAt: now,
        updatedAt: now,
      ).toMap();
      final docRef = _collection.doc(offer.id);
      await docRef.set(data);
      final createdDoc = await docRef.get();
      return OfferDto.fromMap(createdDoc.data()!, createdDoc.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to create offer',
        code: e.code,
      );
    }
  }

  @override
  Future<OfferDto> updateOffer(OfferDto offer, {String? imagePath}) async {
    try {
      String? imageUrl = offer.imageUrl;
      if (imagePath != null) {
        if (offer.imageUrl != null) {
          await _deleteImage(offer.imageUrl!);
        }
        imageUrl = await _uploadImage(imagePath, _offersImagesPath);
      }
      final now = DateTime.now();
      final data = offer.copyWith(
        imageUrl: imageUrl,
        updatedAt: now,
      ).toMap();
      await _collection.doc(offer.id).update(data);
      final updatedDoc = await _collection.doc(offer.id).get();
      return OfferDto.fromMap(updatedDoc.data()!, updatedDoc.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to update offer',
        code: e.code,
      );
    }
  }

  @override
  Future<void> deleteOffer(String offerId) async {
    try {
      final doc = await _collection.doc(offerId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data?['imageUrl'] != null) {
          await _deleteImage(data!['imageUrl'] as String);
        }
      }
      final products = await _offerProductsCollection(offerId).get();
      for (final p in products.docs) {
        await p.reference.delete();
      }
      await _collection.doc(offerId).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to delete offer',
        code: e.code,
      );
    }
  }

  @override
  Future<void> toggleActive(String offerId, bool isActive) async {
    try {
      await _collection.doc(offerId).update({
        FirestoreConstants.isActive: isActive,
        FirestoreConstants.updatedAt: DateTime.now(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to toggle offer active state',
        code: e.code,
      );
    }
  }

  @override
  Future<void> addOfferProduct(String offerId, String productId) async {
    try {
      final docRef = _offerProductsCollection(offerId).doc();
      await docRef.set({
        'offerId': offerId,
        'productId': productId,
        FirestoreConstants.createdAt: DateTime.now(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to add product to offer',
        code: e.code,
      );
    }
  }

  @override
  Future<void> removeOfferProducts(String offerId) async {
    try {
      final products = await _offerProductsCollection(offerId).get();
      for (final p in products.docs) {
        await p.reference.delete();
      }
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: e.message ?? 'Failed to remove offer products',
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
