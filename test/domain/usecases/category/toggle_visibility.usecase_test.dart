import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/repositories/category_repository.dart';
import 'package:fresh_market/domain/usecases/category/toggle_visibility.usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late ToggleVisibilityUseCase useCase;
  late MockCategoryRepository mockRepo;

  setUp(() {
    mockRepo = MockCategoryRepository();
    useCase = ToggleVisibilityUseCase(repository: mockRepo);
  });

  group('ToggleVisibilityUseCase', () {
    test('toggles visibility to hidden', () async {
      when(() => mockRepo.toggleVisibility('cat_001', false))
          .thenAnswer((_) async => const Success(null));

      final result = await useCase('cat_001', false);

      expect(result, isA<Success<void>>());
      verify(() => mockRepo.toggleVisibility('cat_001', false)).called(1);
    });

    test('toggles visibility to visible', () async {
      when(() => mockRepo.toggleVisibility('cat_001', true))
          .thenAnswer((_) async => const Success(null));

      final result = await useCase('cat_001', true);

      expect(result, isA<Success<void>>());
      verify(() => mockRepo.toggleVisibility('cat_001', true)).called(1);
    });

    test('forwards repository failure', () async {
      when(() => mockRepo.toggleVisibility('cat_001', false))
          .thenAnswer((_) async => Failure(
                FirestoreException(message: 'Not found'),
              ));

      final result = await useCase('cat_001', false);

      expect(result, isA<Failure<void>>());
      expect((result as Failure).error.message, 'Not found');
    });
  });
}
