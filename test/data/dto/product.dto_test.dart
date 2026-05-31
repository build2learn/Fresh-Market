import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/data/dto/product.dto.dart';

void main() {
  group('ProductDto', () {
    const testId = 'prod_001';
    final testTime = DateTime(2025, 1, 15, 10, 30, 0);

    final testMap = {
      'nameAr': 'تفاح',
      'nameEn': 'Apples',
      'descriptionAr': 'تفاح طازج',
      'descriptionEn': 'Fresh apples',
      'price': 5.99,
      'weight': 1.0,
      'weightUnitId': 'kg',
      'imageUrl': 'https://example.com/apples.jpg',
      'imageThumbUrl': 'https://example.com/apples_thumb.jpg',
      'categoryId': 'cat_001',
      'isFeatured': true,
      'isAvailable': true,
      'createdAt': testTime,
      'updatedAt': testTime,
    };

    group('fromMap', () {
      test('creates DTO from valid map', () {
        final dto = ProductDto.fromMap(testMap, testId);

        expect(dto.id, testId);
        expect(dto.nameAr, 'تفاح');
        expect(dto.nameEn, 'Apples');
        expect(dto.descriptionAr, 'تفاح طازج');
        expect(dto.descriptionEn, 'Fresh apples');
        expect(dto.price, 5.99);
        expect(dto.weight, 1.0);
        expect(dto.weightUnitId, 'kg');
        expect(dto.imageUrl, 'https://example.com/apples.jpg');
        expect(dto.categoryId, 'cat_001');
        expect(dto.isFeatured, true);
        expect(dto.isAvailable, true);
        expect(dto.createdAt, testTime);
        expect(dto.updatedAt, testTime);
      });

      test('handles null optional fields', () {
        final map = Map<String, dynamic>.from(testMap)
          ..remove('descriptionAr')
          ..remove('descriptionEn')
          ..remove('imageUrl')
          ..remove('imageThumbUrl');
        final dto = ProductDto.fromMap(map, testId);

        expect(dto.descriptionAr, isNull);
        expect(dto.descriptionEn, isNull);
        expect(dto.imageUrl, isNull);
        expect(dto.imageThumbUrl, isNull);
      });

      test('uses defaults for missing fields', () {
        final dto = ProductDto.fromMap({
          'nameAr': 'موز',
          'nameEn': 'Bananas',
          'price': 3.50,
          'weight': 0.5,
          'weightUnitId': 'kg',
          'categoryId': 'cat_001',
          'createdAt': testTime,
          'updatedAt': testTime,
        }, testId);

        expect(dto.isFeatured, false);
        expect(dto.isAvailable, true);
      });
    });

    group('toMap', () {
      test('produces correct map', () {
        final dto = ProductDto(
          id: testId,
          nameAr: 'تفاح',
          nameEn: 'Apples',
          descriptionAr: 'تفاح طازج',
          descriptionEn: 'Fresh apples',
          price: 5.99,
          weight: 1.0,
          weightUnitId: 'kg',
          imageUrl: 'https://example.com/apples.jpg',
          imageThumbUrl: 'https://example.com/apples_thumb.jpg',
          categoryId: 'cat_001',
          isFeatured: true,
          isAvailable: true,
          createdAt: testTime,
          updatedAt: testTime,
        );

        final map = dto.toMap();

        expect(map['id'], testId);
        expect(map['nameAr'], 'تفاح');
        expect(map['nameEn'], 'Apples');
        expect(map['price'], 5.99);
        expect(map['weight'], 1.0);
      });
    });

    group('copyWith', () {
      test('returns same instance when no args', () {
        final dto = ProductDto.fromMap(testMap, testId);
        final copied = dto.copyWith();

        expect(copied.id, dto.id);
        expect(copied.nameAr, dto.nameAr);
        expect(copied.nameEn, dto.nameEn);
      });

      test('overrides specified fields', () {
        final dto = ProductDto.fromMap(testMap, testId);
        final copied = dto.copyWith(nameAr: 'موز', nameEn: 'Bananas');

        expect(copied.nameAr, 'موز');
        expect(copied.nameEn, 'Bananas');
        expect(copied.id, testId);
      });
    });
  });
}
