import 'package:flutter/material.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';

class OfferCard extends StatelessWidget {
  final OfferEntity offer;
  final VoidCallback onTap;

  const OfferCard({
    super.key,
    required this.offer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isExpired = offer.isExpired;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (offer.imageUrl != null)
              Image.network(
                offer.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRtl ? offer.titleAr : offer.titleEn,
                    style: context.textTheme.titleMedium,
                  ),
                  if (offer.descriptionAr != null || offer.descriptionEn != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        isRtl
                            ? (offer.descriptionAr ?? offer.descriptionEn ?? '')
                            : (offer.descriptionEn ?? offer.descriptionAr ?? ''),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (isExpired)
                        Chip(
                          label: Text(context.l10n.expired),
                          backgroundColor: context.colorScheme.errorContainer,
                        )
                      else
                        Chip(
                          label: Text(context.l10n.expiresIn),
                          backgroundColor: context.colorScheme.primaryContainer,
                        ),
                      const Spacer(),
                      if (!isExpired)
                        Text(
                          '${offer.remainingTime.inDays} ${context.l10n.days}',
                          style: context.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
