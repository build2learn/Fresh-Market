import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/domain/repositories/category_repository.dart';
import 'package:fresh_market/domain/usecases/category/get_visible_categories.usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late GetVisibleCategoriesUseCase useCase;
  late MockCategoryRepository mockRepo;

  final testTime = DateTime(2025, 1, 15);
  final visibleCategories = [
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
    useCase = GetVisibleCategoriesUseCase(repository: mockRepo);
  });

  group('GetVisibleCategoriesUseCase', () {
    test('returns only visible categories', () async {
      when(() => mockRepo.getVisibleCategories())
          .thenAnswer((_) async => Success(visibleCategories));

      final result = await useCase();

      expect(result, isA<Success<List<CategoryEntity>>>());
      final data = (result as Success<List<CategoryEntity>>).data;
      expect(data.length, 2);
      expect(data.every((c) => c.isVisible), true);
    });

    test('returns empty list when no visible categories', () async {
      when(() => mockRepo.getVisibleCategories())
          .thenAnswer((_) async => Success(<CategoryEntity>[]));

      final result = await useCase();

      expect(result, isA<Success<List<CategoryEntity>>>());
      expect((result as Success).data, isEmpty);
    });

    test('forwards repository failure', () async {
      when(() => mockRepo.getVisibleCategories())
          .thenAnswer((_) async => Failure(
                FirestoreException(message: 'Network error'),
              ));

      final result = await useCase();

      expect(result, isA<Failure<List<CategoryEntity>>>());
      expect((result as Failure).error.message, 'Network error');
    });
  });
}
