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
              context.formatPrice(product.price),
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
            const SizedBox(height: 4),
            _buildStockBadge(context),
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

  Widget _buildStockBadge(BuildContext context) {
    final stock = product.stockQuantity;
    final alertQty = product.alertQuantity;
    final isAr = context.isRtl;

    if (stock == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: context.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          isAr ? 'نفد من المخزون' : 'Out of Stock',
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onErrorContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (stock <= alertQty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          isAr ? 'مخزون منخفض: $stock' : 'Low Stock: $stock',
          style: context.textTheme.labelSmall?.copyWith(
            color: Colors.amber.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Text(
        isAr ? 'المخزون: $stock' : 'Stock: $stock',
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      );
    }
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
