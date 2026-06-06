import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/data/providers/offer_repository_provider.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/domain/usecases/offer/get_offers.usecase.dart';
import 'package:fresh_market/domain/usecases/product/get_products.usecase.dart';

final _offerDetailProvider = FutureProvider.autoDispose.family<OfferEntity?, String>((ref, id) async {
  final repo = ref.watch(offerRepositoryProvider);
  final useCase = GetOfferUseCase(repository: repo);
  final result = await useCase(id);
  if (result is Success<OfferEntity>) return result.data;
  if (result is Failure<OfferEntity>) throw Exception(result.error.message);
  return null;
});

final _offerProductsProvider = FutureProvider.autoDispose.family<List<ProductEntity>, String>((ref, offerId) async {
  final offerRepo = ref.watch(offerRepositoryProvider);
  final getOfferProducts = GetOfferProductsUseCase(repository: offerRepo);
  final productIdsResult = await getOfferProducts(offerId);
  if (productIdsResult is Failure<List<ProductEntity>>) {
    throw Exception(productIdsResult.error.message);
  }
  final success = productIdsResult as Success<List<ProductEntity>>;
  final productIds = success.data.map((p) => p.id).toList();
  final productRepo = ref.watch(productRepositoryProvider);
  final getProduct = GetProductUseCase(repository: productRepo);
  final products = <ProductEntity>[];
  for (final pid in productIds) {
    final pResult = await getProduct(pid);
    if (pResult is Success<ProductEntity>) {
      products.add(pResult.data);
    }
  }
  return products;
});

class OfferDetailPage extends ConsumerWidget {
  final String offerId;

  const OfferDetailPage({super.key, required this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(_offerDetailProvider(offerId));
    final productsAsync = ref.watch(_offerProductsProvider(offerId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.offersTitle)),
      body: offerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (offer) {
          if (offer == null) {
            return Center(child: Text(context.l10n.errorNotFound));
          }
          return _buildContent(context, ref, offer, productsAsync);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    OfferEntity offer,
    AsyncValue<List<ProductEntity>> productsAsync,
  ) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isExpired = offer.isExpired;

    return ListView(
      children: [
        if (offer.imageUrl != null)
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
            ),
            child: Image.network(
              offer.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(Icons.local_offer, size: 64, color: context.colorScheme.outline),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRtl ? offer.titleAr : offer.titleEn,
                style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (offer.descriptionAr != null || offer.descriptionEn != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    isRtl
                        ? (offer.descriptionAr ?? offer.descriptionEn ?? '')
                        : (offer.descriptionEn ?? offer.descriptionAr ?? ''),
                    style: context.textTheme.bodyLarge,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (isExpired)
                    Chip(
                      label: Text(context.l10n.expired),
                      backgroundColor: context.colorScheme.errorContainer,
                    )
                  else
                    Chip(
                      label: Text(context.l10n.expiresIn),
                      backgroundColor: context.colorScheme.primaryContainer,
                    ),
                  const SizedBox(width: 8),
                  if (!isExpired)
                    Text(
                      '${offer.remainingTime.inDays} ${context.l10n.days}',
                      style: context.textTheme.bodyMedium,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.includeProducts,
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('$e'),
                data: (products) {
                  if (products.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(child: Text(context.l10n.noProducts)),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        leading: product.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  product.imageUrl!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.inventory_2, color: context.colorScheme.outline,
                                  ),
                                ),
                              )
                            : Icon(Icons.inventory_2, color: context.colorScheme.outline),
                        title: Text(
                          isRtl ? product.nameAr : product.nameEn,
                        ),
                        subtitle: Text(
                          context.l10n.priceFormat(product.price.toStringAsFixed(2)),
                        ),
                        onTap: () => context.push(
                          RouteConstants.productDetailPath(product.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
