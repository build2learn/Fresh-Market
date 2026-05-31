import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../domain/entities/product.entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onToggleFeatured;
  final VoidCallback onToggleAvailability;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onToggleFeatured,
    required this.onToggleAvailability,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _buildLeading(context),
        title: Text(
          context.isRtl ? product.nameAr : product.nameEn,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.isRtl ? product.nameEn : product.nameAr,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              context.l10n.priceFormat(product.price.toStringAsFixed(2)),
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              context.l10n.weightFormat(product.weight.toStringAsFixed(1), product.weightUnitId),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                product.isFeatured ? Icons.star : Icons.star_border,
                color: product.isFeatured
                    ? context.colorScheme.tertiary
                    : context.colorScheme.outline,
              ),
              tooltip: context.l10n.featured,
              onPressed: onToggleFeatured,
            ),
            IconButton(
              icon: Icon(
                product.isAvailable ? Icons.check_circle : Icons.cancel,
                color: product.isAvailable
                    ? context.colorScheme.primary
                    : context.colorScheme.error,
              ),
              tooltip: product.isAvailable ? context.l10n.available : context.l10n.unavailable,
              onPressed: onToggleAvailability,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: context.l10n.edit,
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete_outlined,
                  color: context.colorScheme.error),
              tooltip: context.l10n.delete,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (product.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.imageUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(context),
        ),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.inventory_2,
        color: context.colorScheme.onPrimaryContainer,
      ),
    );
  }
}
