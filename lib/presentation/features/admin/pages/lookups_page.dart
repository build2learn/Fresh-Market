import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LookupsPage extends StatelessWidget {
  const LookupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> lookupTypes = [
      {'type': 'Category', 'nameAr': 'الفئات', 'nameEn': 'Categories', 'icon': Icons.category_outlined},
      {'type': 'WeightUnit', 'nameAr': 'وحدات الوزن', 'nameEn': 'Weight Units', 'icon': Icons.scale_outlined},
      {'type': 'ProductType', 'nameAr': 'أنواع المنتجات', 'nameEn': 'Product Types', 'icon': Icons.inventory_2_outlined},
      {'type': 'ProductStatus', 'nameAr': 'حالات المنتجات', 'nameEn': 'Product Statuses', 'icon': Icons.info_outline},
      {'type': 'OfferType', 'nameAr': 'أنواع العروض', 'nameEn': 'Offer Types', 'icon': Icons.local_offer_outlined},
      {'type': 'UserRole', 'nameAr': 'أدوار المستخدمين', 'nameEn': 'User Roles', 'icon': Icons.people_outline},
    ];

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(isRtl ? 'إدارة القوائم' : 'Lookup Management'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: lookupTypes.length,
        itemBuilder: (context, index) {
          final t = lookupTypes[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                context.push('/admin/lookups/list?type=${t['type']}&title=${Uri.encodeComponent(isRtl ? t['nameAr'] : t['nameEn'])}');
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(t['icon'] as IconData, size: 48, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    isRtl ? t['nameAr']! : t['nameEn']!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
