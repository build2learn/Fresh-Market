import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/datasources/firebase/product_firebase_datasource.dart';
import 'package:fresh_market/data/datasources/local/product_local_datasource.dart';
import 'package:fresh_market/data/dto/product.dto.dart';
import 'package:fresh_market/data/repositories/product_repository_impl.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseDataSource extends Mock implements ProductFirebaseDataSource {}

class MockLocalDataSource extends Mock implements ProductLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(ProductDto(
      id: 'fallback',
      nameAr: 'fallback',
      nameEn: 'fallback',
      price: 1.0,
      weight: 1.0,
      weightUnitId: 'kg',
      categoryId: 'cat_fallback',
      isFeatured: false,
      isAvailable: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    registerFallbackValue(<ProductDto>[]);
  });

  late ProductRepositoryImpl repository;
  late MockFirebaseDataSource mockFirebase;
  late MockLocalDataSource mockLocal;

  final testTime = DateTime(2025, 1, 15);
  final testDto = ProductDto(
    id: 'prod_001',
    nameAr: 'تفاح',
    nameEn: 'Apples',
    price: 5.99,
    weight: 1.0,
    weightUnitId: 'kg',
    categoryId: 'cat_001',
    isFeatured: true,
    isAvailable: true,
    createdAt: testTime,
    updatedAt: testTime,
  );

  final testEntity = ProductEntity(
    id: 'prod_001',
    nameAr: 'تفاح',
    nameEn: 'Apples',
    price: 5.99,
    weight: 1.0,
    weightUnitId: 'kg',
    categoryId: 'cat_001',
    isFeatured: true,
    isAvailable: true,
    createdAt: testTime,
    updatedAt: testTime,
  );

  setUp(() {
    mockFirebase = MockFirebaseDataSource();
    mockLocal = MockLocalDataSource();
    when(() => mockLocal.cacheAll(any())).thenAnswer((_) async {});
    repository = ProductRepositoryImpl(
      firebaseDataSource: mockFirebase,
      localDataSource: mockLocal,
    );
  });

  group('getProducts', () {
    test('returns products from firebase successfully', () async {
      when(() => mockFirebase.getProducts(
        limit: any(named: 'limit'),
        lastDoc: any(named: 'lastDoc'),
        categoryId: any(named: 'categoryId'),
      )).thenAnswer((_) async => [testDto]);

      final result = await repository.getProducts();

      expect(result, isA<Success<List<ProductEntity>>>());
      expect((result as Success).data.length, 1);
      expect((result as Success).data.first.nameEn, 'Apples');
      verify(() => mockFirebase.getProducts(
        limit: any(named: 'limit'),
        lastDoc: any(named: 'lastDoc'),
        categoryId: any(named: 'categoryId'),
      )).called(1);
    });

    test('falls back to local cache on firebase failure', () async {
      when(() => mockFirebase.getProducts(
        limit: any(named: 'limit'),
        lastDoc: any(named: 'lastDoc'),
        categoryId: any(named: 'categoryId'),
      )).thenThrow(Exception('Network error'));
      when(() => mockLocal.getAll())
          .thenAnswer((_) async => [testDto]);

      final result = await repository.getProducts();

      expect(result, isA<Success<List<ProductEntity>>>());
      expect((result as Success).data.length, 1);
    });

    test('returns failure when both sources fail', () async {
      when(() => mockFirebase.getProducts(
        limit: any(named: 'limit'),
        lastDoc: any(named: 'lastDoc'),
        categoryId: any(named: 'categoryId'),
      )).thenThrow(Exception('Network error'));
      when(() => mockLocal.getAll())
          .thenAnswer((_) async => []);

      final result = await repository.getProducts();

      expect(result, isA<Failure<List<ProductEntity>>>());
    });
  });

  group('getProduct', () {
    test('returns product when found', () async {
      when(() => mockFirebase.getProduct('prod_001'))
          .thenAnswer((_) async => testDto);

      final result = await repository.getProduct('prod_001');

      expect(result, isA<Success<ProductEntity>>());
      expect((result as Success).data.nameEn, 'Apples');
    });

    test('returns failure when not found', () async {
      when(() => mockFirebase.getProduct('prod_001'))
          .thenAnswer((_) async => null);

      final result = await repository.getProduct('prod_001');

      expect(result, isA<Failure<ProductEntity>>());
    });
  });

  group('getFeaturedProducts', () {
    test('returns featured products', () async {
      when(() => mockFirebase.getFeaturedProducts(limit: any(named: 'limit')))
          .thenAnswer((_) async => [testDto]);

      final result = await repository.getFeaturedProducts();

      expect(result, isA<Success<List<ProductEntity>>>());
      expect((result as Success).data.length, 1);
    });
  });

  group('createProduct', () {
    test('creates product successfully with empty id', () async {
      final newEntity = testEntity.copyWith(id: '');
      when(() => mockFirebase.createProduct(any()))
          .thenAnswer((_) async => testDto);

      final result = await repository.createProduct(newEntity);

      expect(result, isA<Success<ProductEntity>>());
    });

    test('creates product with provided id', () async {
      when(() => mockFirebase.createProduct(any()))
          .thenAnswer((_) async => testDto);

      final result = await repository.createProduct(testEntity);

      expect(result, isA<Success<ProductEntity>>());
      verify(() => mockFirebase.createProduct(any())).called(1);
    });

    test('returns failure on firebase error', () async {
      when(() => mockFirebase.createProduct(any()))
          .thenThrow(Exception('Permission denied'));

      final result = await repository.createProduct(testEntity);

      expect(result, isA<Failure<ProductEntity>>());
    });
  });

  group('deleteProduct', () {
    test('deletes product successfully', () async {
      when(() => mockFirebase.deleteProduct('prod_001'))
          .thenAnswer((_) async {});

      final result = await repository.deleteProduct('prod_001');

      expect(result, isA<Success<void>>());
    });

    test('returns failure on firebase error', () async {
      when(() => mockFirebase.deleteProduct('prod_001'))
          .thenThrow(Exception('Not found'));

      final result = await repository.deleteProduct('prod_001');

      expect(result, isA<Failure<void>>());
    });
  });

  group('toggleFeatured', () {
    test('toggles featured successfully', () async {
      when(() => mockFirebase.toggleFeatured('prod_001', true))
          .thenAnswer((_) async {});

      final result = await repository.toggleFeatured('prod_001', true);

      expect(result, isA<Success<void>>());
    });
  });

  group('toggleAvailability', () {
    test('toggles availability successfully', () async {
      when(() => mockFirebase.toggleAvailability('prod_001', false))
          .thenAnswer((_) async {});

      final result = await repository.toggleAvailability('prod_001', false);

      expect(result, isA<Success<void>>());
    });
  });
}
