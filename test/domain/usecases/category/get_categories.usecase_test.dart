import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/domain/repositories/category_repository.dart';
import 'package:fresh_market/domain/usecases/category/get_categories.usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late GetCategoriesUseCase useCase;
  late MockCategoryRepository mockRepo;

  final testTime = DateTime(2025, 1, 15);
  final testCategories = [
    CategoryEntity(
      id: 'cat_001',
      nameAr: 'فواكه',
      nameEn: 'Fruits',
      isVisible: true,
      sortOrder: 0,
      createdAt: testTime,
      updatedAt: testTime,
    ),
    CategoryEntity(
      id: 'cat_002',
      nameAr: 'خضروات',
      nameEn: 'Vegetables',
      isVisible: true,
      sortOrder: 1,
      createdAt: testTime,
      updatedAt: testTime,
    ),
  ];

  setUp(() {
    mockRepo = MockCategoryRepository();
    useCase = GetCategoriesUseCase(repository: mockRepo);
  });

  test('returns all categories from repository', () async {
    when(() => mockRepo.getCategories())
        .thenAnswer((_) async => Success(testCategories));

    final result = await useCase();

    expect(result, isA<Success<List<CategoryEntity>>>());
    final data = (result as Success<List<CategoryEntity>>).data;
    expect(data.length, 2);
    expect(data[0].nameEn, 'Fruits');
    expect(data[1].nameEn, 'Vegetables');
  });

  test('returns empty list when no categories exist', () async {
    when(() => mockRepo.getCategories())
        .thenAnswer((_) async => Success(<CategoryEntity>[]));

    final result = await useCase();

    expect(result, isA<Success<List<CategoryEntity>>>());
    expect((result as Success).data, isEmpty);
  });

  test('forwards repository failure', () async {
    when(() => mockRepo.getCategories())
        .thenAnswer((_) async => Failure(
              FirestoreException(message: 'Network error'),
            ));

    final result = await useCase();

    expect(result, isA<Failure<List<CategoryEntity>>>());
  });
}
