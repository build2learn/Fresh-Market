import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/data/dto/category.dto.dart';

void main() {
  group('CategoryDto', () {
    const testId = 'cat_001';
    final testTime = DateTime(2025, 1, 15, 10, 30, 0);

    final testMap = {
      'nameAr': 'فواكه',
      'nameEn': 'Fruits',
      'imageUrl': 'https://example.com/fruits.jpg',
      'isVisible': true,
      'isDeleted': false,
      'sortOrder': 1,
      'createdAt': testTime,
      'updatedAt': testTime,
    };

    group('fromMap', () {
      test('creates DTO from valid map', () {
        final dto = CategoryDto.fromMap(testMap, testId);

        expect(dto.id, testId);
        expect(dto.nameAr, 'فواكه');
        expect(dto.nameEn, 'Fruits');
        expect(dto.imageUrl, 'https://example.com/fruits.jpg');
        expect(dto.isVisible, true);
        expect(dto.isDeleted, false);
        expect(dto.sortOrder, 1);
        expect(dto.createdAt, testTime);
        expect(dto.updatedAt, testTime);
      });

      test('handles null imageUrl', () {
        final map = Map<String, dynamic>.from(testMap)..remove('imageUrl');
        final dto = CategoryDto.fromMap(map, testId);

        expect(dto.imageUrl, isNull);
      });

      test('uses defaults for missing fields', () {
        final dto = CategoryDto.fromMap({'nameAr': 'خضروات', 'nameEn': 'Vegetables', 'createdAt': testTime, 'updatedAt': testTime}, testId);

        expect(dto.isVisible, true);
        expect(dto.isDeleted, false);
        expect(dto.sortOrder, 0);
      });
    });

    group('toMap', () {
      test('produces correct map', () {
        final dto = CategoryDto(
          id: testId,
          nameAr: 'فواكه',
          nameEn: 'Fruits',
          imageUrl: 'https://example.com/fruits.jpg',
          isVisible: true,
          isDeleted: false,
          sortOrder: 1,
          createdAt: testTime,
          updatedAt: testTime,
        );

        final map = dto.toMap();

        expect(map['id'], testId);
        expect(map['nameAr'], 'فواكه');
        expect(map['nameEn'], 'Fruits');
        expect(map['imageUrl'], 'https://example.com/fruits.jpg');
        expect(map['isVisible'], true);
        expect(map['isDeleted'], false);
        expect(map['sortOrder'], 1);
        expect(map['createdAt'], testTime);
        expect(map['updatedAt'], testTime);
      });

      test('omits null imageUrl from map', () {
        final dto = CategoryDto(
          id: testId,
          nameAr: 'خضروات',
          nameEn: 'Vegetables',
          isVisible: true,
          isDeleted: false,
          sortOrder: 0,
          createdAt: testTime,
          updatedAt: testTime,
        );

        final map = dto.toMap();

        expect(map['id'], testId);
        expect(map['imageUrl'], isNull);
      });
    });

    group('copyWith', () {
      test('returns same instance when no args', () {
        final dto = CategoryDto.fromMap(testMap, testId);
        final copied = dto.copyWith();

        expect(copied.id, dto.id);
        expect(copied.nameAr, dto.nameAr);
        expect(copied.nameEn, dto.nameEn);
        expect(copied.isVisible, dto.isVisible);
      });

      test('overrides specified fields', () {
        final dto = CategoryDto.fromMap(testMap, testId);
        final copied = dto.copyWith(nameAr: 'خضروات', nameEn: 'Vegetables');

        expect(copied.nameAr, 'خضروات');
        expect(copied.nameEn, 'Vegetables');
        expect(copied.id, testId);
      });
    });
  });
}
