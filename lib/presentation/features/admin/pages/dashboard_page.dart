import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/data/providers/category_repository_provider.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/data/providers/offer_repository_provider.dart';
import 'package:fresh_market/domain/usecases/category/get_categories.usecase.dart';
import 'package:fresh_market/domain/usecases/product/get_products.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/get_offers.usecase.dart';

final _dashboardStatsProvider = FutureProvider.autoDispose<_DashboardStats>((ref) async {
  final categoryRepo = ref.watch(categoryRepositoryProvider);
  final productRepo = ref.watch(productRepositoryProvider);
  final offerRepo = ref.watch(offerRepositoryProvider);

  final getCategories = GetCategoriesUseCase(repository: categoryRepo);
  final getProducts = GetProductsUseCase(repository: productRepo);
  final getOffers = GetOffersUseCase(repository: offerRepo);

  final categoriesResult = await getCategories();
  final productsResult = await getProducts();
  final offersResult = await getOffers();

  return _DashboardStats(
    totalCategories: categoriesResult is Success<List<CategoryEntity>> ? categoriesResult.data.length : 0,
    totalProducts: productsResult is Success<List<ProductEntity>> ? productsResult.data.length : 0,
    totalOffers: offersResult is Success<List<OfferEntity>> ? offersResult.data.length : 0,
  );
});

class _DashboardStats {
  final int totalCategories;
  final int totalProducts;
  final int totalOffers;

  const _DashboardStats({
    required this.totalCategories,
    required this.totalProducts,
    required this.totalOffers,
  });
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.dashboard)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_dashboardStatsProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (stats) => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(
                    icon: Icons.inventory_2_outlined,
                    label: context.l10n.totalProducts,
                    value: '${stats.totalProducts}',
                    color: context.colorScheme.primary,
                    onTap: () => context.push(RouteConstants.adminProducts),
                  ),
                  _StatCard(
                    icon: Icons.category_outlined,
                    label: context.l10n.totalCategories,
                    value: '${stats.totalCategories}',
                    color: context.colorScheme.secondary,
                    onTap: () => context.push(RouteConstants.adminCategories),
                  ),
                  _StatCard(
                    icon: Icons.local_offer_outlined,
                    label: context.l10n.totalOffers,
                    value: '${stats.totalOffers}',
                    color: context.colorScheme.tertiary,
                    onTap: () => context.push(RouteConstants.adminOffers),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n.quickActions,
              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ActionCard(
              icon: Icons.add_circle_outline,
              label: context.l10n.addProduct,
              onTap: () => context.push(RouteConstants.adminProductNew),
            ),
            _ActionCard(
              icon: Icons.add_circle_outline,
              label: context.l10n.addCategory,
              onTap: () => context.push(RouteConstants.adminCategoryNew),
            ),
            _ActionCard(
              icon: Icons.add_circle_outline,
              label: context.l10n.addOffer,
              onTap: () => context.push(RouteConstants.adminOfferNew),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
