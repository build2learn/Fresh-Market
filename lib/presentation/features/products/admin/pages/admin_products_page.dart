import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/enums/request_state.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../providers/product_providers.dart';
import '../../providers/product_list_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_delete_dialog.dart';

class AdminProductsPage extends ConsumerStatefulWidget {
  const AdminProductsPage({super.key});

  @override
  ConsumerState<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends ConsumerState<AdminProductsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListProvider.notifier).startRealtimeSync();
    });
  }

  @override
  void dispose() {
    ref.read(productListProvider.notifier).stopRealtimeSync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.products),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: context.l10n.addProduct,
            onPressed: () => context.push(RouteConstants.adminProductNew),
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: state.products.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => context.push(RouteConstants.adminProductNew),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(ProductListState state) {
    if (state.requestState == RequestState.loading) {
      return const LoadingWidget();
    }
    if (state.requestState == RequestState.failure) {
      return ErrorDisplayWidget(
        message: state.errorMessage ?? context.l10n.errorGeneral,
        onRetry: () => ref.read(productListProvider.notifier).refresh(),
      );
    }
    if (state.products.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: context.l10n.noProducts,
        description: context.l10n.noProductsDesc,
        actionLabel: context.l10n.addProduct,
        onAction: () => context.push(RouteConstants.adminProductNew),
      );
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(productListProvider.notifier).refresh(),
      child: ListView.builder(
        itemCount: state.products.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final product = state.products[index];
          return ProductCard(
            product: product,
            onEdit: () => context.push(
              RouteConstants.adminProductEditPath(product.id),
            ),
            onToggleFeatured: () async {
              final error = await ref
                  .read(productListProvider.notifier)
                  .toggleFeatured(product.id, product.isFeatured);
              if (error != null && mounted) {
                context.showSnackBar(error, isError: true);
              }
            },
            onToggleAvailability: () async {
              final error = await ref
                  .read(productListProvider.notifier)
                  .toggleAvailability(product.id, product.isAvailable);
              if (error != null && mounted) {
                context.showSnackBar(error, isError: true);
              }
            },
            onDelete: () => _showDeleteDialog(product.id, product.nameEn),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => ProductDeleteDialog(
        productName: name,
        onConfirm: () async {
          Navigator.of(ctx).pop();
          final error = await ref
              .read(productListProvider.notifier)
              .deleteProduct(id);
          if (error != null && mounted) {
            context.showSnackBar(error, isError: true);
          } else if (mounted) {
            context.showSnackBar(context.l10n.itemDeleted);
          }
        },
      ),
    );
  }
}
