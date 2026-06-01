import 'dart:async';
import 'dart:math';
import '../../core/errors/app_exception.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/offer.entity.dart';
import '../../domain/entities/product.entity.dart';
import '../../domain/repositories/offer_repository.dart';
import '../datasources/firebase/offer_firebase_datasource.dart';
import '../datasources/local/offer_local_datasource.dart';
import '../models/offer_model.dart';


class OfferRepositoryImpl implements OfferRepository {
  final OfferFirebaseDataSource _firebaseDataSource;
  final OfferLocalDataSource _localDataSource;

  OfferRepositoryImpl({
    required OfferFirebaseDataSource firebaseDataSource,
    required OfferLocalDataSource localDataSource,
  })  : _firebaseDataSource = firebaseDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Result<List<OfferEntity>>> getOffers() async {
    try {
      final dtos = await _firebaseDataSource.getOffers();
      final entities = dtos.map((dto) => OfferModel.fromDto(dto).toEntity()).toList();
      await _localDataSource.cacheAll(dtos);
      return Success(entities);
    } on AppException catch (e) {
      final cached = await _localDataSource.getAll();
      if (cached.isNotEmpty) {
        final entities = cached.map((dto) => OfferModel.fromDto(dto).toEntity()).toList();
        return Success(entities);
      }
      return Failure(e);
    } catch (e) {
      final cached = await _localDataSource.getAll();
      if (cached.isNotEmpty) {
        final entities = cached.map((dto) => OfferModel.fromDto(dto).toEntity()).toList();
        return Success(entities);
      }
      return Failure(FirestoreException(message: 'Failed to load offers'));
    }
  }

  @override
  Future<Result<List<OfferEntity>>> getActiveOffers() async {
    try {
      final dtos = await _firebaseDataSource.getActiveOffers();
      final entities = dtos.map((dto) => OfferModel.fromDto(dto).toEntity()).toList();
      return Success(entities);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to load active offers'));
    }
  }

  @override
  Future<Result<OfferEntity>> getOffer(String id) async {
    try {
      final dto = await _firebaseDataSource.getOffer(id);
      if (dto == null) {
        return Failure(FirestoreException(message: 'Offer not found'));
      }
      return Success(OfferModel.fromDto(dto).toEntity());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to load offer'));
    }
  }

  @override
  Future<Result<List<ProductEntity>>> getOfferProducts(String offerId) async {
    try {
      final dtos = await _firebaseDataSource.getOfferProducts(offerId);
      final productIds = dtos.map((dto) => dto.productId).toList();
      return Success(
        productIds.map((id) => ProductEntity(
          id: id,
          nameAr: '',
          nameEn: '',
          price: 0,
          weight: 0,
          weightUnitId: '',
          categoryId: '',
          isFeatured: false,
          isAvailable: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )).toList(),
      );
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to load offer products'));
    }
  }

  @override
  Stream<List<OfferEntity>> watchActiveOffers() {
    return _firebaseDataSource.watchActiveOffers().map(
      (dtos) => dtos.map((dto) => OfferModel.fromDto(dto).toEntity()).toList(),
    );
  }

  @override
  Future<Result<OfferEntity>> createOffer(
    OfferEntity offer,
    List<String> productIds, {
    String? imagePath,
  }) async {
    try {
      final id = offer.id.isEmpty ? _generateId() : offer.id;
      final dto = OfferModel.fromEntity(offer.copyWith(id: id));
      final created = await _firebaseDataSource.createOffer(dto, imagePath: imagePath);
      for (final productId in productIds) {
        await _firebaseDataSource.addOfferProduct(id, productId);
      }
      return Success(OfferModel.fromDto(created).toEntity());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to create offer'));
    }
  }

  @override
  Future<Result<OfferEntity>> updateOffer(
    OfferEntity offer,
    List<String> productIds, {
    String? imagePath,
  }) async {
    try {
      final dto = OfferModel.fromEntity(offer);
      final updated = await _firebaseDataSource.updateOffer(dto, imagePath: imagePath);
      await _firebaseDataSource.removeOfferProducts(offer.id);
      for (final productId in productIds) {
        await _firebaseDataSource.addOfferProduct(offer.id, productId);
      }
      return Success(OfferModel.fromDto(updated).toEntity());
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to update offer'));
    }
  }

  @override
  Future<Result<void>> toggleActive(String offerId, bool isActive) async {
    try {
      await _firebaseDataSource.toggleActive(offerId, isActive);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to toggle offer active state'));
    }
  }

  @override
  Future<Result<void>> deleteOffer(String offerId) async {
    try {
      await _firebaseDataSource.deleteOffer(offerId);
      return const Success(null);
    } on AppException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(FirestoreException(message: 'Failed to delete offer'));
    }
  }

  String _generateId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
