import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/category.entity.dart';
import 'package:fresh_market/data/providers/category_repository_provider.dart';
import 'package:fresh_market/domain/usecases/category/get_visible_categories.usecase.dart';

final _visibleCategoriesProvider = FutureProvider.autoDispose<List<CategoryEntity>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  final useCase = GetVisibleCategoriesUseCase(repository: repo);
  final result = await useCase();
  if (result is Success<List<CategoryEntity>>) return result.data;
  if (result is Failure<List<CategoryEntity>>) throw Exception(result.error.message);
  throw Exception('Unexpected error');
});

class CategoriesListPage extends ConsumerWidget {
  const CategoriesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(_visibleCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.categories)),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(child: Text(context.l10n.noCategories));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_visibleCategoriesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryTile(category: category);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryEntity category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(RouteConstants.categoryProductsPath(category.id)),
        child: Row(
          children: [
            if (category.imageUrl != null)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                ),
                child: Image.network(
                  category.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(Icons.category, size: 40, color: context.colorScheme.outline),
                  ),
                ),
              )
            else
              Container(
                width: 100,
                height: 100,
                color: context.colorScheme.surfaceContainerHighest,
                child: Icon(Icons.category, size: 40, color: context.colorScheme.outline),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRtl ? category.nameAr : category.nameEn,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (category.nameAr.isNotEmpty && category.nameEn.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          isRtl ? category.nameEn : category.nameAr,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.chevron_right, color: context.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
