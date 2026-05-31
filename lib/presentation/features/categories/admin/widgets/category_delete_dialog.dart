import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';

class CategoryDeleteDialog extends StatelessWidget {
  final String categoryName;
  final VoidCallback onConfirm;

  const CategoryDeleteDialog({
    super.key,
    required this.categoryName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.deleteCategory),
      content: Text(
        '${context.l10n.confirmDeleteCategory}\n\n${context.l10n.actionCannotBeUndone}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: context.colorScheme.error,
          ),
          child: Text(context.l10n.delete),
        ),
      ],
    );
  }
}
