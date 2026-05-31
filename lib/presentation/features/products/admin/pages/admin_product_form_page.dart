import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/presentation/features/categories/providers/category_providers.dart';
import 'package:fresh_market/presentation/features/weight_units/providers/weight_unit_providers.dart';
import '../../providers/product_providers.dart';
import '../widgets/product_form_widget.dart';

final _pickedImagePathProvider = StateProvider<String?>((ref) => null);

class AdminProductFormPage extends ConsumerWidget {
  final String? editId;

  const AdminProductFormPage({super.key, this.editId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(productFormProvider(editId));
    final isEdit = editId != null;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final categoriesState = ref.watch(categoryListProvider);
    final categoryItems = categoriesState.categories.map((cat) {
      return DropdownMenuItem<String>(
        value: cat.id,
        child: Text(isRtl ? cat.nameAr : cat.nameEn),
      );
    }).toList();

    final weightUnitsState = ref.watch(weightUnitListProvider);
    final weightUnitItems = weightUnitsState.weightUnits.map((unit) {
      return DropdownMenuItem<String>(
        value: unit.id,
        child: Text(isRtl ? unit.nameAr : unit.nameEn),
      );
    }).toList();

    final pickedImagePath = ref.watch(_pickedImagePathProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? context.l10n.editProduct : context.l10n.addProduct),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ProductFormWidget(
          state: formState,
          categoryItems: categoryItems,
          weightUnitItems: weightUnitItems,
          pickedImagePath: pickedImagePath,
          onNameArChanged: (v) => ref.read(productFormProvider(editId).notifier).setNameAr(v),
          onNameEnChanged: (v) => ref.read(productFormProvider(editId).notifier).setNameEn(v),
          onDescriptionArChanged: (v) => ref.read(productFormProvider(editId).notifier).setDescriptionAr(v),
          onDescriptionEnChanged: (v) => ref.read(productFormProvider(editId).notifier).setDescriptionEn(v),
          onPriceChanged: (v) => ref.read(productFormProvider(editId).notifier).setPrice(v),
          onWeightChanged: (v) => ref.read(productFormProvider(editId).notifier).setWeight(v),
          onWeightUnitIdChanged: (v) => ref.read(productFormProvider(editId).notifier).setWeightUnitId(v),
          onCategoryIdChanged: (v) => ref.read(productFormProvider(editId).notifier).setCategoryId(v),
          onFeaturedChanged: (v) => ref.read(productFormProvider(editId).notifier).setFeatured(v),
          onAvailableChanged: (v) => ref.read(productFormProvider(editId).notifier).setAvailable(v),
          onImageSelected: (filePath) {
            ref.read(_pickedImagePathProvider.notifier).state = filePath;
          },
          onSubmit: () async {
            final imagePath = ref.read(_pickedImagePathProvider);
            final error = await ref.read(productFormProvider(editId).notifier).submit(imagePath: imagePath);
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
