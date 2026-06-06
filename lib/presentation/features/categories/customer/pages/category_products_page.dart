import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/domain/usecases/product/get_products.usecase.dart';
import '../../providers/category_providers.dart';

final _categoryProductsProvider = FutureProvider.autoDispose.family<List<ProductEntity>, String>((ref, categoryId) async {
  final repo = ref.watch(productRepositoryProvider);
  final useCase = GetProductsUseCase(repository: repo);
  final result = await useCase(limit: 50, categoryId: categoryId);
  if (result is Success<List<ProductEntity>>) return result.data;
  if (result is Failure<List<ProductEntity>>) throw Exception(result.error.message);
  throw Exception('Unexpected error');
});

class CategoryProductsPage extends ConsumerWidget {
  final String categoryId;

  const CategoryProductsPage({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(categoryListProvider);
    final category = categoryState.categories.where((c) => c.id == categoryId).firstOrNull;
    final productsAsync = ref.watch(_categoryProductsProvider(categoryId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category != null
              ? (context.isRtl ? category.nameAr : category.nameEn)
              : context.l10n.products,
        ),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.l10n.errorGeneral),
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: context.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.noProducts,
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.noProductsDesc,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_categoryProductsProvider(categoryId)),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductGridItem(product: product);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  final ProductEntity product;
  const _ProductGridItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RouteConstants.productDetailPath(product.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
              ),
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.inventory_2, size: 40, color: context.colorScheme.outline),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.inventory_2, size: 40, color: context.colorScheme.outline),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRtl ? product.nameAr : product.nameEn,
                      style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.priceFormat(product.price.toStringAsFixed(2)),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    Text(
                      context.l10n.weightFormat(product.weight.toStringAsFixed(1), product.weightUnitId),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
