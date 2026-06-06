import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/data/providers/offer_repository_provider.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';
import 'package:fresh_market/domain/usecases/product/get_products.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/get_offers.usecase.dart';
import 'package:fresh_market/presentation/features/offers/customer/widgets/offer_card.dart';

final _featuredProductsProvider = FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final useCase = GetFeaturedProductsUseCase(repository: repo);
  final result = await useCase(limit: 10);
  if (result is Success<List<ProductEntity>>) return result.data;
  if (result is Failure<List<ProductEntity>>) throw Exception(result.error.message);
  throw Exception('Unexpected error');
});

final _activeOffersProvider = FutureProvider.autoDispose<List<OfferEntity>>((ref) async {
  final repo = ref.watch(offerRepositoryProvider);
  final useCase = GetActiveOffersUseCase(repository: repo);
  final result = await useCase();
  if (result is Success<List<OfferEntity>>) return result.data;
  if (result is Failure<List<OfferEntity>>) throw Exception(result.error.message);
  throw Exception('Unexpected error');
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(_featuredProductsProvider);
    final offersAsync = ref.watch(_activeOffersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.homeTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_featuredProductsProvider);
          ref.invalidate(_activeOffersProvider);
        },
        child: ListView(
          children: [
            _FeaturedProductsSection(featuredAsync: featuredAsync),
            if (featuredAsync.hasValue && featuredAsync.value!.isNotEmpty)
              const Divider(height: 1),
            _ActiveOffersSection(offersAsync: offersAsync),
          ],
        ),
      ),
    );
  }
}

class _FeaturedProductsSection extends StatelessWidget {
  final AsyncValue<List<ProductEntity>> featuredAsync;

  const _FeaturedProductsSection({required this.featuredAsync});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.featuredProducts,
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        featuredAsync.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('$e', style: TextStyle(color: context.colorScheme.error)),
          ),
          data: (products) {
            if (products.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(context.l10n.noProducts),
              );
            }
            return SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _ProductCard(product: product);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ActiveOffersSection extends StatelessWidget {
  final AsyncValue<List<OfferEntity>> offersAsync;

  const _ActiveOffersSection({required this.offersAsync});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.offers,
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () => context.push(RouteConstants.offerList),
                child: Text(context.l10n.viewAll),
              ),
            ],
          ),
        ),
        offersAsync.when(
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('$e', style: TextStyle(color: context.colorScheme.error)),
          ),
          data: (offers) {
            if (offers.isEmpty) {
              return const SizedBox.shrink();
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return OfferCard(
                  offer: offer,
                  onTap: () => context.push(RouteConstants.offerDetailPath(offer.id)),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductEntity product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RouteConstants.productDetailPath(product.id)),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
