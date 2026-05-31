import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../domain/entities/category.entity.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final bool isReordering;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleVisibility;
  final VoidCallback onDelete;
  final bool showRestoreButton;

  const CategoryCard({
    super.key,
    required this.category,
    this.isReordering = false,
    this.onEdit,
    this.onToggleVisibility,
    required this.onDelete,
    this.showRestoreButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildLeading(context),
        title: Text(
          context.isRtl ? category.nameAr : category.nameEn,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          context.isRtl ? category.nameEn : category.nameAr,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showRestoreButton)
              IconButton(
                icon: Icon(Icons.restore_from_trash_outlined,
                    color: context.colorScheme.primary),
                tooltip: context.l10n.restore,
                onPressed: isReordering ? null : onDelete,
              )
            else ...[
              if (onToggleVisibility != null)
                IconButton(
                  icon: Icon(
                    category.isVisible ? Icons.visibility : Icons.visibility_off,
                    color: category.isVisible
                        ? context.colorScheme.primary
                        : context.colorScheme.outline,
                  ),
                  tooltip: category.isVisible
                      ? context.l10n.hideCategory
                      : context.l10n.showCategory,
                  onPressed: isReordering ? null : onToggleVisibility,
                ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: context.l10n.edit,
                  onPressed: isReordering ? null : onEdit,
                ),
              IconButton(
                icon: Icon(Icons.delete_outlined,
                    color: context.colorScheme.error),
                tooltip: context.l10n.delete,
                onPressed: isReordering ? null : onDelete,
              ),
            ],
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (category.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          category.imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _leadingPlaceholder(context),
        ),
      );
    }
    return _leadingPlaceholder(context);
  }

  Widget _leadingPlaceholder(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.category,
        color: context.colorScheme.onPrimaryContainer,
      ),
    );
  }
}
