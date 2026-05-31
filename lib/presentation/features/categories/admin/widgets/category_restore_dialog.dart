import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';

class CategoryRestoreDialog extends StatelessWidget {
  final String categoryName;
  final VoidCallback onConfirm;

  const CategoryRestoreDialog({
    super.key,
    required this.categoryName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.restoreCategory),
      content: Text(context.l10n.confirmRestoreCategory),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: onConfirm,
          child: Text(context.l10n.restore),
        ),
      ],
    );
  }
}
