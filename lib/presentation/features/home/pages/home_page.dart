import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/data/providers/offer_repository_provider.dart';
import 'package:fresh_market/domain/usecases/product/get_products.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/get_offers.usecase.dart';
import 'package:fresh_market/presentation/features/categories/providers/category_providers.dart';
import 'package:fresh_market/domain/usecases/category/get_visible_categories.usecase.dart';
import 'package:fresh_market/presentation/features/cart/providers/cart_provider.dart';

final _featuredProductsProvider = FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final useCase = GetFeaturedProductsUseCase(repository: repo);
  final result = await useCase(limit: 10);
  if (result is Success<List<ProductEntity>>) return result.data;
  if (result is Failure<List<ProductEntity>>) throw Exception(result.error.message);
  throw Exception('Unexpected error');
});

final _latestProductsProvider = FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final useCase = GetProductsUseCase(repository: repo);
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

final _visibleCategoriesProvider = FutureProvider.autoDispose<List<CategoryEntity>>((ref) async {
  final useCase = ref.watch(getVisibleCategoriesUseCaseProvider);
  final result = await useCase();
  if (result is Success<List<CategoryEntity>>) return result.data;
  if (result is Failure<List<CategoryEntity>>) throw Exception(result.error.message);
  throw Exception('Unexpected error');
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(_featuredProductsProvider);
    final latestAsync = ref.watch(_latestProductsProvider);
    final offersAsync = ref.watch(_activeOffersProvider);
    final categoriesAsync = ref.watch(_visibleCategoriesProvider);

    final cartCount = ref.watch(cartProvider).fold<int>(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(RouteConstants.search),
          ),
          IconButton(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => context.push(RouteConstants.cart),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_featuredProductsProvider);
          ref.invalidate(_latestProductsProvider);
          ref.invalidate(_activeOffersProvider);
          ref.invalidate(_visibleCategoriesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _ActiveOffersCarouselSection(offersAsync: offersAsync),
            const Divider(height: 16),
            _CategoriesSection(categoriesAsync: categoriesAsync),
            const Divider(height: 16),
            _FeaturedProductsSection(featuredAsync: featuredAsync),
            const Divider(height: 16),
            _LatestProductsSection(latestAsync: latestAsync),
          ],
        ),
      ),
    );
  }
}

class _ActiveOffersCarouselSection extends StatelessWidget {
  final AsyncValue<List<OfferEntity>> offersAsync;

  const _ActiveOffersCarouselSection({required this.offersAsync});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
            height: 160,
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
            return CarouselSlider.builder(
              itemCount: offers.length,
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                enlargeCenterPage: true,
                viewportFraction: 0.9,
              ),
              itemBuilder: (context, index, realIndex) {
                final offer = offers[index];
                return GestureDetector(
                  onTap: () => context.push(RouteConstants.offerDetailPath(offer.id)),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        if (offer.imageUrl != null)
                          Positioned.fill(
                            child: Image.network(
                              offer.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: context.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.local_offer, size: 48),
                              ),
                            ),
                          )
                        else
                          Positioned.fill(
                            child: Container(
                              color: context.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.local_offer, size: 48),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black87],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Text(
                              Directionality.of(context) == TextDirection.rtl
                                  ? offer.titleAr
                                  : offer.titleEn,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final AsyncValue<List<CategoryEntity>> categoriesAsync;

  const _CategoriesSection({required this.categoriesAsync});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            context.l10n.categories,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        categoriesAsync.when(
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('$e', style: TextStyle(color: context.colorScheme.error)),
          ),
          data: (categories) {
            if (categories.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(context.l10n.noCategories),
              );
            }
            return SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isRtl = Directionality.of(context) == TextDirection.rtl;
                  return InkWell(
                    onTap: () => context.push(RouteConstants.categoryProductsPath(cat.id)),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: cat.imageUrl != null
                                ? Image.network(
                                    cat.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.category),
                                  )
                                : const Icon(Icons.category),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isRtl ? cat.nameAr : cat.nameEn,
                            style: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            context.l10n.featuredProducts,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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

class _LatestProductsSection extends StatelessWidget {
  final AsyncValue<List<ProductEntity>> latestAsync;

  const _LatestProductsSection({required this.latestAsync});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            context.l10n.sortNewest,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        latestAsync.when(
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
                        context.formatPrice(product.price),
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
