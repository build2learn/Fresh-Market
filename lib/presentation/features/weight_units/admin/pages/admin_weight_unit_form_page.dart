import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import '../../providers/weight_unit_form_provider.dart';
import '../../providers/weight_unit_providers.dart';
import '../widgets/weight_unit_form.dart';

class AdminWeightUnitFormPage extends ConsumerWidget {
  final String? editId;

  const AdminWeightUnitFormPage({super.key, this.editId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(weightUnitFormProvider(editId));
    final isEdit = editId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Weight Unit' : 'Add Weight Unit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: WeightUnitFormWidget(
          state: formState,
          onNameArChanged: (value) =>
              ref.read(weightUnitFormProvider(editId).notifier).setNameAr(value),
          onNameEnChanged: (value) =>
              ref.read(weightUnitFormProvider(editId).notifier).setNameEn(value),
          onAbbrChanged: (value) =>
              ref.read(weightUnitFormProvider(editId).notifier).setAbbr(value),
          onSubmit: () async {
            final error = await ref.read(weightUnitFormProvider(editId).notifier).submit();
            if (error == null && context.mounted) {
              context.showSnackBar(
                isEdit ? context.l10n.changesSaved : context.l10n.itemCreated,
              );
              context.pop();
            } else if (error != null && context.mounted) {
              context.showSnackBar(error, isError: true);
            }
          },
        ),
      ),
    );
  }
}
