import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';

class WeightUnitDeleteDialog extends StatelessWidget {
  final String weightUnitName;
  final VoidCallback onConfirm;

  const WeightUnitDeleteDialog({
    super.key,
    required this.weightUnitName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Weight Unit'),
      content: Text(
        'Are you sure you want to delete "$weightUnitName"?\n\n${context.l10n.actionCannotBeUndone}',
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
