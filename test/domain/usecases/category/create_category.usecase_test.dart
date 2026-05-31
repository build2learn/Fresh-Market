import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/errors/app_exception.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/repositories/category_repository.dart';
import 'package:fresh_market/domain/usecases/category/create_category.usecase.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements CategoryRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(CategoryEntity(
      id: 'fallback',
      nameAr: 'fallback',
      nameEn: 'fallback',
      isVisible: true,
      sortOrder: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  });

  late CreateCategoryUseCase useCase;
  late MockRepo mockRepo;

  final testTime = DateTime(2025, 1, 15);
  final validEntity = CategoryEntity(
    id: '',
    nameAr: 'فواكه',
    nameEn: 'Fruits',
    isVisible: true,
    sortOrder: 0,
    createdAt: testTime,
    updatedAt: testTime,
  );

  setUp(() {
    mockRepo = MockRepo();
    useCase = CreateCategoryUseCase(repository: mockRepo);
  });

  group('CreateCategoryUseCase', () {
    test('creates category with valid names', () async {
      when(() => mockRepo.createCategory(any()))
          .thenAnswer((_) async => Success(validEntity));

      final result = await useCase(validEntity);

      expect(result, isA<Success<CategoryEntity>>());
    });

    test('rejects empty Arabic name', () async {
      final entity = validEntity.copyWith(nameAr: '');

      final result = await useCase(entity);

      expect(result, isA<Failure<CategoryEntity>>());
      expect((result as Failure).error, isA<ValidationException>());
      verifyNever(() => mockRepo.createCategory(any()));
    });

    test('rejects empty English name', () async {
      final entity = validEntity.copyWith(nameEn: '');

      final result = await useCase(entity);

      expect(result, isA<Failure<CategoryEntity>>());
      expect((result as Failure).error, isA<ValidationException>());
      verifyNever(() => mockRepo.createCategory(any()));
    });

    test('rejects whitespace-only names', () async {
      final entity = validEntity.copyWith(nameAr: '   ', nameEn: '   ');

      final result = await useCase(entity);

      expect(result, isA<Failure<CategoryEntity>>());
    });

    test('forwards repository error', () async {
      when(() => mockRepo.createCategory(any()))
          .thenAnswer((_) async => Failure(
                FirestoreException(message: 'Permission denied'),
              ));

      final result = await useCase(validEntity);

      expect(result, isA<Failure<CategoryEntity>>());
      expect((result as Failure).error.message, 'Permission denied');
    });
  });
}
