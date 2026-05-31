import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/repositories/product_repository.dart';
import 'package:fresh_market/domain/usecases/product/create_product.usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements ProductRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(ProductEntity(
      id: '',
      nameAr: 'fallback',
      nameEn: 'fallback',
      price: 1.0,
      weight: 1.0,
      weightUnitId: 'kg',
      categoryId: 'cat_fallback',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  });

  late CreateProductUseCase useCase;
  late MockRepo mockRepo;

  final testTime = DateTime(2025, 1, 15);
  final validEntity = ProductEntity(
    id: '',
    nameAr: 'تفاح',
    nameEn: 'Apples',
    price: 5.99,
    weight: 1.0,
    weightUnitId: 'kg',
    categoryId: 'cat_001',
    createdAt: testTime,
    updatedAt: testTime,
  );

  setUp(() {
    mockRepo = MockRepo();
    useCase = CreateProductUseCase(repository: mockRepo);
  });

  group('CreateProductUseCase', () {
    test('creates product with all valid fields', () async {
      when(() => mockRepo.createProduct(any()))
          .thenAnswer((_) async => Success(validEntity));

      final result = await useCase(validEntity);

      expect(result, isA<Success<ProductEntity>>());
    });

    test('rejects empty Arabic name', () async {
      final entity = validEntity.copyWith(nameAr: '');

      final result = await useCase(entity);

      expect(result, isA<Failure<ProductEntity>>());
      expect((result as Failure).error, isA<ValidationException>());
      verifyNever(() => mockRepo.createProduct(any()));
    });

    test('rejects empty English name', () async {
      final entity = validEntity.copyWith(nameEn: '');

      final result = await useCase(entity);

      expect(result, isA<Failure<ProductEntity>>());
      expect((result as Failure).error, isA<ValidationException>());
      verifyNever(() => mockRepo.createProduct(any()));
    });

    test('rejects zero price', () async {
      final entity = validEntity.copyWith(price: 0);

      final result = await useCase(entity);

      expect(result, isA<Failure<ProductEntity>>());
    });

    test('rejects zero weight', () async {
      final entity = validEntity.copyWith(weight: 0);

      final result = await useCase(entity);

      expect(result, isA<Failure<ProductEntity>>());
    });

    test('rejects empty weight unit', () async {
      final entity = validEntity.copyWith(weightUnitId: '');

      final result = await useCase(entity);

      expect(result, isA<Failure<ProductEntity>>());
    });

    test('rejects empty category', () async {
      final entity = validEntity.copyWith(categoryId: '');

      final result = await useCase(entity);

      expect(result, isA<Failure<ProductEntity>>());
    });

    test('forwards repository error', () async {
      when(() => mockRepo.createProduct(any()))
          .thenAnswer((_) async => Failure(
                FirestoreException(message: 'Permission denied'),
              ));

      final result = await useCase(validEntity);

      expect(result, isA<Failure<ProductEntity>>());
      expect((result as Failure).error.message, 'Permission denied');
    });
  });
}
