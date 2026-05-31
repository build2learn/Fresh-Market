import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/enums/request_state.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../providers/category_providers.dart';
import '../../providers/category_list_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/category_delete_dialog.dart';
import '../widgets/category_restore_dialog.dart';

class AdminCategoriesPage extends ConsumerStatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  ConsumerState<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends ConsumerState<AdminCategoriesPage> {
  bool _showDeleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryListProvider.notifier).startRealtimeSync();
    });
  }

  @override
  void dispose() {
    ref.read(categoryListProvider.notifier).stopRealtimeSync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_showDeleted ? context.l10n.deletedCategories : context.l10n.categories),
        actions: [
          IconButton(
            icon: Icon(state.categories.isNotEmpty ? Icons.add : Icons.restore_from_trash_outlined),
            tooltip: _showDeleted ? context.l10n.categories : context.l10n.deletedCategories,
            onPressed: _showDeleted
                ? () => setState(() => _showDeleted = false)
                : () => setState(() => _showDeleted = true),
          ),
          if (!_showDeleted)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: context.l10n.addCategory,
              onPressed: () => context.push(RouteConstants.adminCategoryNew),
            ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: !_showDeleted && state.categories.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => context.push(RouteConstants.adminCategoryNew),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody(CategoryListState state) {
    if (state.requestState == RequestState.loading) {
      return const LoadingWidget();
    }
    if (state.requestState == RequestState.failure) {
      return ErrorDisplayWidget(
        message: state.errorMessage ?? context.l10n.errorGeneral,
        onRetry: () => ref.read(categoryListProvider.notifier).refresh(),
      );
    }
    if (state.categories.isEmpty) {
      return EmptyStateWidget(
        icon: _showDeleted ? Icons.restore_from_trash_outlined : Icons.category_outlined,
        title: _showDeleted ? context.l10n.deletedCategories : context.l10n.noCategories,
        actionLabel: context.l10n.addCategory,
        onAction: () => context.push(RouteConstants.adminCategoryNew),
      );
    }
    return _buildList(state);
  }

  Widget _buildList(CategoryListState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(categoryListProvider.notifier).refresh(),
      child: ReorderableListView.builder(
        itemCount: state.categories.length,
        padding: const EdgeInsets.all(16),
        onReorder: (oldIndex, newIndex) {
          ref.read(categoryListProvider.notifier).reorder(oldIndex, newIndex);
        },
        proxyDecorator: (child, index, animation) {
          return Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final category = state.categories[index];
          return CategoryCard(
            key: ValueKey(category.id),
            category: category,
            isReordering: state.isReordering,
            onEdit: _showDeleted
                ? null
                : () => context.push(
                      RouteConstants.adminCategoryEditPath(category.id),
                    ),
            onToggleVisibility: _showDeleted
                ? null
                : () async {
                    final error = await ref
                        .read(categoryListProvider.notifier)
                        .toggleVisibility(category.id, category.isVisible);
                    if (error != null && mounted) {
                      context.showSnackBar(error, isError: true);
                    }
                  },
            onDelete: () => _showDeleted
                ? _showRestoreDialog(category.id, category.nameEn)
                : _showDeleteDialog(category.id, category.nameEn),
            showRestoreButton: _showDeleted,
          );
        },
      ),
    );
  }

  void _showDeleteDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => CategoryDeleteDialog(
        categoryName: name,
        onConfirm: () async {
          Navigator.of(ctx).pop();
          final error = await ref
              .read(categoryListProvider.notifier)
              .deleteCategory(id);
          if (error != null && mounted) {
            context.showSnackBar(error, isError: true);
          } else if (mounted) {
            context.showSnackBar(context.l10n.itemDeleted);
          }
        },
      ),
    );
  }

  void _showRestoreDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => CategoryRestoreDialog(
        categoryName: name,
        onConfirm: () async {
          Navigator.of(ctx).pop();
          final error = await ref
              .read(categoryListProvider.notifier)
              .restoreCategory(id);
          if (error != null && mounted) {
            context.showSnackBar(error, isError: true);
          } else if (mounted) {
            context.showSnackBar(context.l10n.itemRestored);
          }
        },
      ),
    );
  }
}
