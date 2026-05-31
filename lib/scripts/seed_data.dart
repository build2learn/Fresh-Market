import 'package:cloud_firestore/cloud_firestore.dart';

abstract final class SeedData {
  SeedData._();

  static List<Map<String, dynamic>> categories() => [
        {
          'nameAr': 'خضروات',
          'nameEn': 'Vegetables',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 1,
        },
        {
          'nameAr': 'فواكه',
          'nameEn': 'Fruits',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 2,
        },
        {
          'nameAr': 'لحوم',
          'nameEn': 'Meat',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 3,
        },
        {
          'nameAr': 'دواجن',
          'nameEn': 'Poultry',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 4,
        },
        {
          'nameAr': 'أسماك',
          'nameEn': 'Seafood',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 5,
        },
        {
          'nameAr': 'ألبان وبيض',
          'nameEn': 'Dairy & Eggs',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 6,
        },
        {
          'nameAr': 'مخبوزات',
          'nameEn': 'Bakery',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 7,
        },
        {
          'nameAr': 'مشروبات',
          'nameEn': 'Beverages',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 8,
        },
        {
          'nameAr': 'حلويات',
          'nameEn': 'Sweets & Desserts',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 9,
        },
        {
          'nameAr': 'بهارات',
          'nameEn': 'Spices',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 10,
        },
        {
          'nameAr': 'زيوت وصلصات',
          'nameEn': 'Oils & Sauces',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 11,
        },
        {
          'nameAr': 'أرز وحبوب',
          'nameEn': 'Rice & Grains',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 12,
        },
        {
          'nameAr': 'معلبات',
          'nameEn': 'Canned Food',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 13,
        },
        {
          'nameAr': 'مجمدة',
          'nameEn': 'Frozen Food',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 14,
        },
        {
          'nameAr': 'عناية شخصية',
          'nameEn': 'Personal Care',
          'isVisible': true,
          'isDeleted': false,
          'sortOrder': 15,
        },
      ];

  static List<Map<String, dynamic>> weightUnits() => [
        {
          'nameAr': 'كيلو جرام',
          'nameEn': 'Kilogram',
          'abbr': 'كجم',
          'sortOrder': 1,
        },
        {
          'nameAr': 'جرام',
          'nameEn': 'Gram',
          'abbr': 'جم',
          'sortOrder': 2,
        },
        {
          'nameAr': 'رطل',
          'nameEn': 'Pound',
          'abbr': 'رطل',
          'sortOrder': 3,
        },
        {
          'nameAr': 'لتر',
          'nameEn': 'Liter',
          'abbr': 'لتر',
          'sortOrder': 4,
        },
        {
          'nameAr': 'ملليلتر',
          'nameEn': 'Milliliter',
          'abbr': 'مل',
          'sortOrder': 5,
        },
        {
          'nameAr': 'قطعة',
          'nameEn': 'Piece',
          'abbr': 'قطعة',
          'sortOrder': 6,
        },
        {
          'nameAr': 'علبة',
          'nameEn': 'Pack',
          'abbr': 'علبة',
          'sortOrder': 7,
        },
      ];

  static List<Map<String, dynamic>> products(
      Map<String, String> categoryIds, Map<String, String> weightUnitIds) {
    return [
      {
        'nameAr': 'طماطم',
        'nameEn': 'Tomatoes',
        'descriptionAr': 'طماطم طازجة من أفضل المزارع المحلية',
        'descriptionEn': 'Fresh tomatoes from local farms',
        'price': 4.50,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['خضروات']!,
        'isFeatured': true,
        'isAvailable': true,
      },
      {
        'nameAr': 'خيار',
        'nameEn': 'Cucumbers',
        'descriptionAr': 'خيار طازج مقرمش',
        'descriptionEn': 'Fresh crunchy cucumbers',
        'price': 3.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['خضروات']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'بصل أحمر',
        'nameEn': 'Red Onions',
        'descriptionAr': 'بصل أحمر طازج',
        'descriptionEn': 'Fresh red onions',
        'price': 2.50,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['خضروات']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'تفاح أحمر',
        'nameEn': 'Red Apples',
        'descriptionAr': 'تفاح أحمر فاخر مستورد من أمريكا',
        'descriptionEn': 'Premium red apples imported from USA',
        'price': 8.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['فواكه']!,
        'isFeatured': true,
        'isAvailable': true,
      },
      {
        'nameAr': 'موز',
        'nameEn': 'Bananas',
        'descriptionAr': 'موز طازج من الفلبين',
        'descriptionEn': 'Fresh bananas from Philippines',
        'price': 5.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['فواكه']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'برتقال',
        'nameEn': 'Oranges',
        'descriptionAr': 'برتقال بلدي عصير',
        'descriptionEn': 'Juicy local oranges',
        'price': 4.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['فواكه']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'لحم بقري مفروم',
        'nameEn': 'Ground Beef',
        'descriptionAr': 'لحم بقري طازج مفروم ناعم',
        'descriptionEn': 'Fresh ground beef',
        'price': 42.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['لحوم']!,
        'isFeatured': true,
        'isAvailable': true,
      },
      {
        'nameAr': 'استيك بقري',
        'nameEn': 'Beef Steak',
        'descriptionAr': 'استيك بقري طري عالي الجودة',
        'descriptionEn': 'Tender high-quality beef steak',
        'price': 65.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['لحوم']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'دجاج كامل',
        'nameEn': 'Whole Chicken',
        'descriptionAr': 'دجاج طازج كامل الوزن',
        'descriptionEn': 'Fresh whole chicken',
        'price': 22.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['دواجن']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'صدر دجاج',
        'nameEn': 'Chicken Breast',
        'descriptionAr': 'صدر دجاج طازج خالي من العظم والجلد',
        'descriptionEn': 'Fresh boneless skinless chicken breast',
        'price': 35.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['دواجن']!,
        'isFeatured': true,
        'isAvailable': true,
      },
      {
        'nameAr': 'سلمون نرويجي',
        'nameEn': 'Norwegian Salmon',
        'descriptionAr': 'سلمون نرويجي طازج مدخن',
        'descriptionEn': 'Fresh smoked Norwegian salmon',
        'price': 85.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['أسماك']!,
        'isFeatured': true,
        'isAvailable': true,
      },
      {
        'nameAr': 'جمبري كبير',
        'nameEn': 'Jumbo Shrimp',
        'descriptionAr': 'جمبري كبير الحجم طازج',
        'descriptionEn': 'Fresh jumbo shrimp',
        'price': 55.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['أسماك']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'حليب طازج',
        'nameEn': 'Fresh Milk',
        'descriptionAr': 'حليب طازج كامل الدسم',
        'descriptionEn': 'Full cream fresh milk',
        'price': 6.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['l']!,
        'categoryId': categoryIds['ألبان وبيض']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'بيض بلدي',
        'nameEn': 'Free-Range Eggs',
        'descriptionAr': 'بيض بلدي طازج 30 حبة',
        'descriptionEn': 'Fresh free-range eggs 30-pack',
        'price': 18.00,
        'weight': 30.0,
        'weightUnitId': weightUnitIds['piece']!,
        'categoryId': categoryIds['ألبان وبيض']!,
        'isFeatured': true,
        'isAvailable': true,
      },
      {
        'nameAr': 'جبنة فيتا',
        'nameEn': 'Feta Cheese',
        'descriptionAr': 'جبنة فيتا يونانية مالحة',
        'descriptionEn': 'Salty Greek feta cheese',
        'price': 15.00,
        'weight': 400.0,
        'weightUnitId': weightUnitIds['g']!,
        'categoryId': categoryIds['ألبان وبيض']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'خبز عربي كبير',
        'nameEn': 'Large Pita Bread',
        'descriptionAr': 'خبز عربي طازج 6 حبات',
        'descriptionEn': 'Fresh pita bread 6 pieces',
        'price': 3.50,
        'weight': 6.0,
        'weightUnitId': weightUnitIds['piece']!,
        'categoryId': categoryIds['مخبوزات']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'كرواسون',
        'nameEn': 'Croissant',
        'descriptionAr': 'كرواسون فرنسي طري بالزبدة',
        'descriptionEn': 'Soft French butter croissant',
        'price': 2.50,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['piece']!,
        'categoryId': categoryIds['مخبوزات']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'مياه معدنية',
        'nameEn': 'Mineral Water',
        'descriptionAr': 'مياه معدنية طبيعية 1.5 لتر',
        'descriptionEn': 'Natural mineral water 1.5L',
        'price': 1.50,
        'weight': 1.5,
        'weightUnitId': weightUnitIds['l']!,
        'categoryId': categoryIds['مشروبات']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'عصير برتقال طبيعي',
        'nameEn': 'Fresh Orange Juice',
        'descriptionAr': 'عصير برتقال طبيعي 100٪',
        'descriptionEn': '100% natural orange juice',
        'price': 7.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['l']!,
        'categoryId': categoryIds['مشروبات']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'تمور سكري',
        'nameEn': 'Sukari Dates',
        'descriptionAr': 'تمور سكري ملكي فاخرة من القصيم',
        'descriptionEn': 'Premium Sukari dates from Qassim',
        'price': 35.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['حلويات']!,
        'isFeatured': true,
        'isAvailable': true,
      },
      {
        'nameAr': 'عسل سدر جبلي',
        'nameEn': 'Mountain Sidr Honey',
        'descriptionAr': 'عسل سدر جبلي طبيعي 100٪',
        'descriptionEn': '100% natural mountain Sidr honey',
        'price': 120.00,
        'weight': 500.0,
        'weightUnitId': weightUnitIds['g']!,
        'categoryId': categoryIds['حلويات']!,
        'isFeatured': true,
        'isAvailable': true,
      },
      {
        'nameAr': 'زيت زيتون بكر',
        'nameEn': 'Extra Virgin Olive Oil',
        'descriptionAr': 'زيت زيتون بكر ممتاز عضوي',
        'descriptionEn': 'Organic extra virgin olive oil',
        'price': 45.00,
        'weight': 750.0,
        'weightUnitId': weightUnitIds['ml']!,
        'categoryId': categoryIds['زيوت وصلصات']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'أرز بسمتي هندي',
        'nameEn': 'Indian Basmati Rice',
        'descriptionAr': 'أرز بسمتي هندي فاخر طويل الحبة',
        'descriptionEn': 'Premium long-grain Indian Basmati rice',
        'price': 25.00,
        'weight': 5.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['أرز وحبوب']!,
        'isFeatured': true,
        'isAvailable': true,
      },
      {
        'nameAr': 'فول مدمس',
        'nameEn': 'Fava Beans',
        'descriptionAr': 'فول مدمس معلب جاهز',
        'descriptionEn': 'Canned ready-to-eat fava beans',
        'price': 4.50,
        'weight': 400.0,
        'weightUnitId': weightUnitIds['g']!,
        'categoryId': categoryIds['معلبات']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'تونة بالزيت',
        'nameEn': 'Tuna in Oil',
        'descriptionAr': 'تونة بالزيت النباتي شرائح',
        'descriptionEn': 'Tuna chunks in vegetable oil',
        'price': 6.00,
        'weight': 185.0,
        'weightUnitId': weightUnitIds['g']!,
        'categoryId': categoryIds['معلبات']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'خضار مشكلة مجمدة',
        'nameEn': 'Frozen Mixed Vegetables',
        'descriptionAr': 'خضار مشكلة مجمدة (بازلاء، جزر، ذرة)',
        'descriptionEn': 'Frozen mixed vegetables (peas, carrots, corn)',
        'price': 8.00,
        'weight': 1.0,
        'weightUnitId': weightUnitIds['kg']!,
        'categoryId': categoryIds['مجمدة']!,
        'isFeatured': false,
        'isAvailable': true,
      },
      {
        'nameAr': 'صابون يد سائل',
        'nameEn': 'Liquid Hand Soap',
        'descriptionAr': 'صابون يد سائل معقم برائحة اللافندر',
        'descriptionEn': 'Antibacterial liquid hand soap lavender scent',
        'price': 12.00,
        'weight': 500.0,
        'weightUnitId': weightUnitIds['ml']!,
        'categoryId': categoryIds['عناية شخصية']!,
        'isFeatured': false,
        'isAvailable': true,
      },
    ];
  }

  static List<Map<String, dynamic>> offers() => [
        {
          'titleAr': 'تخفيضات الصيف',
          'titleEn': 'Summer Sale',
          'descriptionAr': 'تخفيضات كبيرة على الفواكه والخضروات الطازجة',
          'descriptionEn': 'Big discounts on fresh fruits and vegetables',
          'isActive': true,
        },
        {
          'titleAr': 'عرض اللحوم الطازجة',
          'titleEn': 'Fresh Meat Offer',
          'descriptionAr': 'خصم 20٪ على جميع أنواع اللحوم الطازجة',
          'descriptionEn': '20% off on all fresh meat',
          'isActive': true,
        },
        {
          'titleAr': 'عرض الألبان',
          'titleEn': 'Dairy Deal',
          'descriptionAr': 'اشتر 2 واحصل على 1 مجاناً من منتجات الألبان',
          'descriptionEn': 'Buy 2 Get 1 Free on all dairy products',
          'isActive': true,
        },
        {
          'titleAr': 'العسل والتمور',
          'titleEn': 'Honey & Dates',
          'descriptionAr': 'خصم 15٪ على جميع أنواع العسل والتمور',
          'descriptionEn': '15% off on all honey and dates',
          'isActive': false,
        },
      ];
}

class FirestoreSeeder {
  final FirebaseFirestore _firestore;

  FirestoreSeeder({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<void> seedAll({bool overwrite = false}) async {
    print('=== Starting Firestore seeding ===');

    final categoryIds = await _seedCategories(overwrite);
    final weightUnitIds = await _seedWeightUnits(overwrite);
    await _seedProducts(categoryIds, weightUnitIds, overwrite);
    await _seedOffers(overwrite);

    print('=== Firestore seeding complete ===');
  }

  Future<Map<String, String>> _seedCategories(bool overwrite) async {
    final ref = _firestore.collection('categories');
    final ids = <String, String>{};

    for (final cat in SeedData.categories()) {
      final nameEn = cat['nameEn'] as String;
      final existing = await ref.where('nameEn', isEqualTo: nameEn).limit(1).get();

      if (existing.docs.isEmpty || overwrite) {
        final now = DateTime.now();
        final data = {
          ...cat,
          'createdAt': now,
          'updatedAt': now,
          'imageUrl': null,
        };

        if (existing.docs.isNotEmpty && overwrite) {
          await existing.docs.first.reference.update(data);
          ids[nameEn] = existing.docs.first.id;
        } else {
          final doc = await ref.add(data);
          ids[nameEn] = doc.id;
        }
      } else {
        ids[nameEn] = existing.docs.first.id;
      }

      print('  Category: $nameEn -> ${ids[nameEn]}');
    }

    return ids;
  }

  Future<Map<String, String>> _seedWeightUnits(bool overwrite) async {
    final ref = _firestore.collection('weight_units');
    final ids = <String, String>{};

    for (final unit in SeedData.weightUnits()) {
      final nameEn = unit['nameEn'] as String;
      final existing = await ref.where('nameEn', isEqualTo: nameEn).limit(1).get();

      if (existing.docs.isEmpty || overwrite) {
        final now = DateTime.now();
        final data = {
          ...unit,
          'createdAt': now,
          'updatedAt': now,
        };

        if (existing.docs.isNotEmpty && overwrite) {
          await existing.docs.first.reference.update(data);
          ids[nameEn] = existing.docs.first.id;
        } else {
          final doc = await ref.add(data);
          ids[nameEn] = doc.id;
        }
      } else {
        ids[nameEn] = existing.docs.first.id;
      }

      print('  Weight Unit: $nameEn -> ${ids[nameEn]}');
    }

    return ids;
  }

  Future<void> _seedProducts(
    Map<String, String> categoryIds,
    Map<String, String> weightUnitIds,
    bool overwrite,
  ) async {
    final ref = _firestore.collection('products');

    for (final product in SeedData.products(categoryIds, weightUnitIds)) {
      final nameEn = product['nameEn'] as String;
      final existing = await ref.where('nameEn', isEqualTo: nameEn).limit(1).get();

      if (existing.docs.isEmpty || overwrite) {
        final now = DateTime.now();
        final data = {
          ...product,
          'createdAt': now,
          'updatedAt': now,
        };

        if (existing.docs.isNotEmpty && overwrite) {
          await existing.docs.first.reference.update(data);
        } else {
          await ref.add(data);
        }
      }

      print('  Product: $nameEn');
    }
  }

  Future<void> _seedOffers(bool overwrite) async {
    final ref = _firestore.collection('offers');

    for (final offer in SeedData.offers()) {
      final titleEn = offer['titleEn'] as String;
      final existing =
          await ref.where('titleEn', isEqualTo: titleEn).limit(1).get();

      if (existing.docs.isEmpty || overwrite) {
        final now = DateTime.now();
        final data = {
          ...offer,
          'startDate': now,
          'endDate': now.add(const Duration(days: 14)),
          'createdAt': now,
          'updatedAt': now,
        };

        if (existing.docs.isNotEmpty && overwrite) {
          await existing.docs.first.reference.update(data);
        } else {
          await ref.add(data);
        }
      }

      print('  Offer: $titleEn');
    }
  }
}
