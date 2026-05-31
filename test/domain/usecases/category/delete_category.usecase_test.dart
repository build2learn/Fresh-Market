import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/repositories/category_repository.dart';
import 'package:fresh_market/domain/usecases/category/delete_category.usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late DeleteCategoryUseCase useCase;
  late MockCategoryRepository mockRepo;

  setUp(() {
    mockRepo = MockCategoryRepository();
    useCase = DeleteCategoryUseCase(repository: mockRepo);
  });

  test('deletes category successfully', () async {
    when(() => mockRepo.deleteCategory('cat_001'))
        .thenAnswer((_) async => const Success(null));

    final result = await useCase('cat_001');

    expect(result, isA<Success<void>>());
    verify(() => mockRepo.deleteCategory('cat_001')).called(1);
  });

  test('forwards repository failure', () async {
    when(() => mockRepo.deleteCategory('cat_001'))
        .thenAnswer((_) async => Failure(
              FirestoreException(message: 'Not found'),
            ));

    final result = await useCase('cat_001');

    expect(result, isA<Failure<void>>());
    verify(() => mockRepo.deleteCategory('cat_001')).called(1);
  });
}
