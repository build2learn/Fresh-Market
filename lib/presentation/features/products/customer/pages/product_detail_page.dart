import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';

import 'package:fresh_market/presentation/features/cart/providers/cart_provider.dart';

final _productDetailProvider = FutureProvider.family<ProductEntity?, String>((ref, id) async {
  final repo = ref.watch(productRepositoryProvider);
  final result = await repo.getProduct(id);
  if (result is Success<ProductEntity>) return result.data;
  return null;
});

final _quantityProvider = StateProvider.family.autoDispose<int, String>((ref, id) => 1);

class ProductDetailPage extends ConsumerWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(_productDetailProvider(productId));
    final quantity = ref.watch(_quantityProvider(productId));
 
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.productDetail),
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (product) {
          if (product == null) {
            return Center(child: Text(context.l10n.errorNotFound));
          }
          return _buildContent(context, ref, product, quantity);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ProductEntity product, int quantity) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (product.imageUrl != null)
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest,
              ),
              child: Image.network(
                product.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Icon(Icons.inventory_2, size: 64, color: context.colorScheme.outline),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.isRtl ? product.nameAr : product.nameEn,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (context.isRtl && product.nameEn.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.nameEn,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (!context.isRtl && product.nameAr.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.nameAr,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  context.formatPrice(product.price),
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.scale, size: 16, color: context.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.weightFormat(product.weight.toStringAsFixed(1), product.weightUnitId),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (!product.isAvailable)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Chip(
                      label: Text(context.l10n.unavailable),
                      backgroundColor: context.colorScheme.errorContainer,
                    ),
                  ),
                if (product.descriptionAr != null || product.descriptionEn != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.productDescription,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.isRtl
                        ? (product.descriptionAr ?? product.descriptionEn ?? '')
                        : (product.descriptionEn ?? product.descriptionAr ?? ''),
                    style: context.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 24),
                // Quantity Selector & Add to Cart
                if (product.isAvailable) ...[
                  Card(
                    elevation: 0,
                    color: context.colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: context.colorScheme.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.l10n.quantity,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton.filledTonal(
                                    onPressed: quantity > 1
                                        ? () => ref.read(_quantityProvider(productId).notifier).state--
                                        : null,
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      '$quantity',
                                      style: context.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton.filledTonal(
                                    onPressed: () => ref.read(_quantityProvider(productId).notifier).state++,
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: () {
                                ref.read(cartProvider.notifier).addToCart(product, quantity: quantity);
                                context.showSnackBar(
                                  context.isRtl
                                      ? 'تمت إضافة المنتج إلى عربة التسوق!'
                                      : 'Product added to shopping cart!',
                                );
                              },
                              icon: const Icon(Icons.add_shopping_cart),
                              label: Text(
                                '${context.l10n.addToCart} (${context.formatPrice(product.price * quantity)})',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
