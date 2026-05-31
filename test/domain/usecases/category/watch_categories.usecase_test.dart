import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/domain/repositories/category_repository.dart';
import 'package:fresh_market/domain/usecases/category/watch_categories.usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late WatchCategoriesUseCase useCase;
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
  ];

  setUp(() {
    mockRepo = MockCategoryRepository();
    useCase = WatchCategoriesUseCase(repository: mockRepo);
  });

  group('WatchCategoriesUseCase', () {
    test('emits category list from repository stream', () async {
      final streamController = StreamController<List<CategoryEntity>>();
      when(() => mockRepo.watchCategories()).thenAnswer((_) => streamController.stream);

      final result = useCase();

      expect(
        result,
        emits(testCategories),
      );

      streamController.add(testCategories);
      await streamController.close();
    });

    test('emits empty list when categories removed', () async {
      final streamController = StreamController<List<CategoryEntity>>();
      when(() => mockRepo.watchCategories()).thenAnswer((_) => streamController.stream);

      final result = useCase();

      expect(
        result,
        emitsInOrder([testCategories, <CategoryEntity>[]]),
      );

      streamController.add(testCategories);
      streamController.add([]);
      await streamController.close();
    });

    test('forwards repository stream errors', () async {
      final streamController = StreamController<List<CategoryEntity>>();
      when(() => mockRepo.watchCategories()).thenAnswer((_) => streamController.stream);

      final result = useCase();

      expect(
        result,
        emitsError(isA<Exception>()),
      );

      streamController.addError(Exception('Stream error'));
      await streamController.close();
    });
  });
}
