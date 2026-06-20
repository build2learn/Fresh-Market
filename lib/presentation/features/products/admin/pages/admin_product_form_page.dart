import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/presentation/features/admin/providers/lookup_providers.dart';
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

    final categoriesAsync = ref.watch(lookupListProvider('Category'));
    final weightUnitsAsync = ref.watch(lookupListProvider('WeightUnit'));
    final productTypesAsync = ref.watch(lookupListProvider('ProductType'));
    final productStatusesAsync = ref.watch(lookupListProvider('ProductStatus'));

    final categoryItems = categoriesAsync.valueOrNull?.where((l) => l.isActive).map((cat) {
      return DropdownMenuItem<String>(
        value: cat.code,
        child: Text(isRtl ? cat.nameAr : cat.nameEn),
      );
    }).toList() ?? [];

    final weightUnitItems = weightUnitsAsync.valueOrNull?.where((l) => l.isActive).map((unit) {
      return DropdownMenuItem<String>(
        value: unit.code,
        child: Text(isRtl ? unit.nameAr : unit.nameEn),
      );
    }).toList() ?? [];

    final productTypeItems = productTypesAsync.valueOrNull?.where((l) => l.isActive).map((type) {
      return DropdownMenuItem<String>(
        value: type.code,
        child: Text(isRtl ? type.nameAr : type.nameEn),
      );
    }).toList() ?? [];

    final productStatusItems = productStatusesAsync.valueOrNull?.where((l) => l.isActive).map((status) {
      return DropdownMenuItem<String>(
        value: status.code,
        child: Text(isRtl ? status.nameAr : status.nameEn),
      );
    }).toList() ?? [];

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
          productTypeItems: productTypeItems,
          productStatusItems: productStatusItems,
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
          onProductTypeChanged: (v) => ref.read(productFormProvider(editId).notifier).setProductType(v),
          onProductStatusChanged: (v) => ref.read(productFormProvider(editId).notifier).setStatus(v),
          onStockQuantityChanged: (v) => ref.read(productFormProvider(editId).notifier).setStockQuantity(v),
          onMinStockChanged: (v) => ref.read(productFormProvider(editId).notifier).setMinStock(v),
          onAlertQuantityChanged: (v) => ref.read(productFormProvider(editId).notifier).setAlertQuantity(v),
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
