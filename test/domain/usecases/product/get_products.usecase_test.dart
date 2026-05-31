import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/repositories/product_repository.dart';
import 'package:fresh_market/domain/usecases/product/get_products.usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements ProductRepository {}

void main() {
  late GetProductsUseCase useCase;
  late MockRepo mockRepo;

  final testTime = DateTime(2025, 1, 15);
  final testProducts = [
    ProductEntity(
      id: 'prod_001',
      nameAr: 'تفاح',
      nameEn: 'Apples',
      price: 5.99,
      weight: 1.0,
      weightUnitId: 'kg',
      categoryId: 'cat_001',
      createdAt: testTime,
      updatedAt: testTime,
    ),
  ];

  setUp(() {
    mockRepo = MockRepo();
    useCase = GetProductsUseCase(repository: mockRepo);
  });

  test('returns all products from repository', () async {
    when(() => mockRepo.getProducts(limit: any(named: 'limit')))
        .thenAnswer((_) async => Success(testProducts));

    final result = await useCase();

    expect(result, isA<Success<List<ProductEntity>>>());
    final data = (result as Success<List<ProductEntity>>).data;
    expect(data.length, 1);
    expect(data[0].nameEn, 'Apples');
  });

  test('returns empty list when no products exist', () async {
    when(() => mockRepo.getProducts(limit: any(named: 'limit')))
        .thenAnswer((_) async => Success(<ProductEntity>[]));

    final result = await useCase();

    expect(result, isA<Success<List<ProductEntity>>>());
    expect((result as Success).data, isEmpty);
  });

  test('forwards repository failure', () async {
    when(() => mockRepo.getProducts(limit: any(named: 'limit')))
        .thenAnswer((_) async => Failure(
              FirestoreException(message: 'Network error'),
            ));

    final result = await useCase();

    expect(result, isA<Failure<List<ProductEntity>>>());
  });
}
