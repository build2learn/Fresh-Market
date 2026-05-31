import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import '../../providers/category_form_provider.dart';
import '../widgets/category_form.dart';

class AdminCategoryFormPage extends ConsumerWidget {
  final String? editId;

  const AdminCategoryFormPage({super.key, this.editId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(categoryFormProvider(editId));
    final isEdit = editId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? context.l10n.editCategory : context.l10n.addCategory),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CategoryFormWidget(
          state: formState,
          onNameArChanged: (value) =>
              ref.read(categoryFormProvider(editId).notifier).setNameAr(value),
          onNameEnChanged: (value) =>
              ref.read(categoryFormProvider(editId).notifier).setNameEn(value),
          onVisibilityChanged: (value) =>
              ref.read(categoryFormProvider(editId).notifier).setVisibility(value),
          onImageSelected: (url) =>
              ref.read(categoryFormProvider(editId).notifier).setImageUrl(url),
          onSubmit: () async {
            final error = await ref.read(categoryFormProvider(editId).notifier).submit();
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
