import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import '../../providers/category_providers.dart';

class CategoryProductsPage extends ConsumerWidget {
  final String categoryId;

  const CategoryProductsPage({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(categoryListProvider);
    final category = categoryState.categories.where((c) => c.id == categoryId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category != null
              ? (context.isRtl ? category.nameAr : category.nameEn)
              : context.l10n.products,
        ),
      ),
      body: Center(
        child: Text(
          '${context.l10n.products} - $categoryId',
          style: context.textTheme.titleMedium,
        ),
      ),
    );
  }
}
