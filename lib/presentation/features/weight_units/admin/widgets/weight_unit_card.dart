import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../domain/entities/weight_unit.entity.dart';

class WeightUnitCard extends StatelessWidget {
  final WeightUnitEntity weightUnit;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const WeightUnitCard({
    super.key,
    required this.weightUnit,
    this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              weightUnit.abbr,
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          context.isRtl ? weightUnit.nameAr : weightUnit.nameEn,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          context.isRtl ? weightUnit.nameEn : weightUnit.nameAr,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
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
}
