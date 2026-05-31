import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/repositories/category_repository.dart';
import 'package:fresh_market/domain/usecases/category/reorder_categories.usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late ReorderCategoriesUseCase useCase;
  late MockCategoryRepository mockRepo;

  setUp(() {
    mockRepo = MockCategoryRepository();
    useCase = ReorderCategoriesUseCase(repository: mockRepo);
  });

  group('ReorderCategoriesUseCase', () {
    test('reorders categories successfully', () async {
      final ids = ['cat_003', 'cat_001', 'cat_002'];
      when(() => mockRepo.reorderCategories(ids))
          .thenAnswer((_) async => const Success(null));

      final result = await useCase(ids);

      expect(result, isA<Success<void>>());
      verify(() => mockRepo.reorderCategories(ids)).called(1);
    });

    test('handles single element list', () async {
      final ids = ['cat_001'];
      when(() => mockRepo.reorderCategories(ids))
          .thenAnswer((_) async => const Success(null));

      final result = await useCase(ids);

      expect(result, isA<Success<void>>());
    });

    test('forwards repository failure', () async {
      final ids = ['cat_001', 'cat_002'];
      when(() => mockRepo.reorderCategories(ids))
          .thenAnswer((_) async => Failure(
                FirestoreException(message: 'Reorder failed'),
              ));

      final result = await useCase(ids);

      expect(result, isA<Failure<void>>());
      expect((result as Failure).error.message, 'Reorder failed');
    });
  });
}
