import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';

class ProductDeleteDialog extends StatelessWidget {
  final String productName;
  final VoidCallback onConfirm;

  const ProductDeleteDialog({
    super.key,
    required this.productName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.deleteProduct),
      content: Text(
        '${context.l10n.confirmDeleteProduct}\n\n${context.l10n.actionCannotBeUndone}',
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
