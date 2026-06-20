import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/enums/request_state.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import '../providers/search_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final isRtl = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: context.l10n.searchProducts,
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchProvider.notifier).clearSearch();
                      },
                    )
                  : null,
            ),
            onChanged: (val) {
              setState(() {}); // update clear button visibility
              ref.read(searchProvider.notifier).onQueryChanged(val);
            },
          ),
        ),
      ),
      body: _buildBody(state, isRtl),
    );
  }

  Widget _buildBody(SearchState state, bool isRtl) {
    if (state.state == RequestState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.state == RequestState.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.errorMessage ?? context.l10n.errorGeneral,
                style: context.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref.read(searchProvider.notifier).onQueryChanged(_searchController.text);
                },
                child: Text(context.l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (state.state == RequestState.idle || _searchController.text.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: context.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              context.l10n.searchProducts,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: context.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              context.l10n.noResults,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final product = state.results[index];
        return _ProductGridItem(product: product);
      },
    );
  }
}

class _ProductGridItem extends StatelessWidget {
  final ProductEntity product;
  const _ProductGridItem({required this.product});

  @override
  Widget build(BuildContext context) {
    final isRtl = context.isRtl;
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
                      context.formatPrice(product.price),
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
