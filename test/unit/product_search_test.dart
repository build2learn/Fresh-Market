import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/core/services/mock_repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('MockProductRepository search test for Arabic, English, and partial terms', () async {
    final prefs = await SharedPreferences.getInstance();
    final repo = MockProductRepository(prefs);

    // Initial seed contains:
    // prod_minced_meat: nameAr="لحمة مفرومة", nameEn="Minced Meat"
    // prod_meat_box: nameAr="صندوق لحوم", nameEn="Meat Box"
    // prod_chicken: nameAr="دجاج طازج", nameEn="Fresh Chicken"
    // prod_frozen_burger: nameAr="برجر مجمد", nameEn="Frozen Burger"

    // 1. Search "لحم" (should match "لحمة مفرومة")
    final resultAr = await repo.searchProducts('لحم');
    expect(resultAr, isA<Success<List<ProductEntity>>>());
    final dataAr = (resultAr as Success<List<ProductEntity>>).data;
    expect(dataAr.length, 1);
    expect(dataAr.any((p) => p.id == 'prod_minced_meat'), true);

    // 2. Search "meat" (should match "Minced Meat" and "Meat Box")
    final resultEn = await repo.searchProducts('meat');
    expect(resultEn, isA<Success<List<ProductEntity>>>());
    final dataEn = (resultEn as Success<List<ProductEntity>>).data;
    expect(dataEn.length, 2);
    expect(dataEn.any((p) => p.id == 'prod_minced_meat'), true);
    expect(dataEn.any((p) => p.id == 'prod_meat_box'), true);

    // 3. Search "box" (should match "Meat Box")
    final resultBox = await repo.searchProducts('box');
    expect(resultBox, isA<Success<List<ProductEntity>>>());
    final dataBox = (resultBox as Success<List<ProductEntity>>).data;
    expect(dataBox.length, 1);
    expect(dataBox[0].id, 'prod_meat_box');
  });
}
