import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/datasources/firebase/category_firebase_datasource.dart';
import 'package:fresh_market/data/datasources/local/category_local_datasource.dart';
import 'package:fresh_market/data/dto/category.dto.dart';
import 'package:fresh_market/data/repositories/category_repository_impl.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseDataSource extends Mock implements CategoryFirebaseDataSource {}

class MockLocalDataSource extends Mock implements CategoryLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(CategoryDto(
      id: 'fallback',
      nameAr: 'fallback',
      nameEn: 'fallback',
      isVisible: true,
      sortOrder: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    registerFallbackValue(<CategoryDto>[]);
  });

  late CategoryRepositoryImpl repository;
  late MockFirebaseDataSource mockFirebase;
  late MockLocalDataSource mockLocal;

  final testTime = DateTime(2025, 1, 15);
  final testDto = CategoryDto(
    id: 'cat_001',
    nameAr: 'فواكه',
    nameEn: 'Fruits',
    isVisible: true,
    sortOrder: 0,
    createdAt: testTime,
    updatedAt: testTime,
  );

  final testEntity = CategoryEntity(
    id: 'cat_001',
    nameAr: 'فواكه',
    nameEn: 'Fruits',
    isVisible: true,
    sortOrder: 0,
    createdAt: testTime,
    updatedAt: testTime,
  );

  setUp(() {
    mockFirebase = MockFirebaseDataSource();
    mockLocal = MockLocalDataSource();
    when(() => mockLocal.cacheAll(any())).thenAnswer((_) async {});
    repository = CategoryRepositoryImpl(
      firebaseDataSource: mockFirebase,
      localDataSource: mockLocal,
    );
  });

  group('getCategories', () {
    test('returns categories from firebase successfully', () async {
      when(() => mockFirebase.getCategories(limit: any(named: 'limit')))
          .thenAnswer((_) async => [testDto]);

      final result = await repository.getCategories();

      expect(result, isA<Success<List<CategoryEntity>>>());
      expect((result as Success).data.length, 1);
      expect((result as Success).data.first.nameEn, 'Fruits');
      verify(() => mockFirebase.getCategories(limit: any(named: 'limit'))).called(1);
      verify(() => mockLocal.cacheAll(any())).called(1);
    });

    test('falls back to local cache on firebase failure', () async {
      when(() => mockFirebase.getCategories(limit: any(named: 'limit')))
          .thenThrow(Exception('Network error'));
      when(() => mockLocal.getAll())
          .thenAnswer((_) async => [testDto]);

      final result = await repository.getCategories();

      expect(result, isA<Success<List<CategoryEntity>>>());
      expect((result as Success).data.length, 1);
    });

    test('returns failure when both sources fail', () async {
      when(() => mockFirebase.getCategories(limit: any(named: 'limit')))
          .thenThrow(Exception('Network error'));
      when(() => mockLocal.getAll())
          .thenAnswer((_) async => []);

      final result = await repository.getCategories();

      expect(result, isA<Failure<List<CategoryEntity>>>());
    });
  });

  group('createCategory', () {
    test('creates category successfully with empty id', () async {
      final newEntity = testEntity.copyWith(id: '');
      when(() => mockFirebase.createCategory(any()))
          .thenAnswer((_) async => testDto);

      final result = await repository.createCategory(newEntity);

      expect(result, isA<Success<CategoryEntity>>());
    });

    test('creates category with provided id', () async {
      when(() => mockFirebase.createCategory(any()))
          .thenAnswer((_) async => testDto);

      final result = await repository.createCategory(testEntity);

      expect(result, isA<Success<CategoryEntity>>());
      verify(() => mockFirebase.createCategory(any())).called(1);
    });

    test('returns failure on firebase error', () async {
      when(() => mockFirebase.createCategory(any()))
          .thenThrow(Exception('Permission denied'));

      final result = await repository.createCategory(testEntity);

      expect(result, isA<Failure<CategoryEntity>>());
    });
  });

  group('deleteCategory (soft delete)', () {
    test('soft deletes category successfully', () async {
      when(() => mockFirebase.softDeleteCategory('cat_001'))
          .thenAnswer((_) async {});

      final result = await repository.deleteCategory('cat_001');

      expect(result, isA<Success<void>>());
      verify(() => mockFirebase.softDeleteCategory('cat_001')).called(1);
    });

    test('returns failure on firebase error', () async {
      when(() => mockFirebase.softDeleteCategory('cat_001'))
          .thenThrow(Exception('Not found'));

      final result = await repository.deleteCategory('cat_001');

      expect(result, isA<Failure<void>>());
    });
  });

  group('restoreCategory', () {
    test('restores category successfully', () async {
      when(() => mockFirebase.restoreCategory('cat_001'))
          .thenAnswer((_) async {});

      final result = await repository.restoreCategory('cat_001');

      expect(result, isA<Success<void>>());
      verify(() => mockFirebase.restoreCategory('cat_001')).called(1);
    });

    test('returns failure on firebase error', () async {
      when(() => mockFirebase.restoreCategory('cat_001'))
          .thenThrow(Exception('Not found'));

      final result = await repository.restoreCategory('cat_001');

      expect(result, isA<Failure<void>>());
    });
  });

  group('toggleVisibility', () {
    test('toggles visibility successfully', () async {
      when(() => mockFirebase.toggleVisibility('cat_001', true))
          .thenAnswer((_) async {});

      final result = await repository.toggleVisibility('cat_001', true);

      expect(result, isA<Success<void>>());
      verify(() => mockFirebase.toggleVisibility('cat_001', true)).called(1);
    });
  });

  group('reorderCategories', () {
    test('reorders successfully', () async {
      final ids = ['cat_001', 'cat_002', 'cat_003'];
      when(() => mockFirebase.reorderCategories(ids))
          .thenAnswer((_) async {});

      final result = await repository.reorderCategories(ids);

      expect(result, isA<Success<void>>());
    });
  });
}
