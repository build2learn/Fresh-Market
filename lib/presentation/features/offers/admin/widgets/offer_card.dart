import 'package:flutter/material.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';

class OfferCard extends StatelessWidget {
  final OfferEntity offer;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const OfferCard({
    super.key,
    required this.offer,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isExpired = offer.isExpired;
    final statusColor = isExpired
        ? context.colorScheme.error
        : offer.isActive
            ? context.colorScheme.primary
            : context.colorScheme.outline;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildLeading(context),
        title: Text(
          isRtl ? offer.titleAr : offer.titleEn,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (offer.descriptionAr != null || offer.descriptionEn != null)
              Text(
                isRtl
                    ? (offer.descriptionAr ?? offer.descriptionEn ?? '')
                    : (offer.descriptionEn ?? offer.descriptionAr ?? ''),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isExpired
                      ? Icons.timer_off_outlined
                      : offer.isActive
                          ? Icons.check_circle
                          : Icons.cancel,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isExpired
                      ? context.l10n.expired
                      : offer.isActive
                          ? context.l10n.active
                          : context.l10n.inactive,
                  style: context.textTheme.bodySmall?.copyWith(color: statusColor),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                offer.isActive ? Icons.toggle_on : Icons.toggle_off_outlined,
                color: offer.isActive ? context.colorScheme.primary : null,
              ),
              onPressed: onToggleActive,
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outlined),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (offer.imageUrl == null) return null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        offer.imageUrl!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
