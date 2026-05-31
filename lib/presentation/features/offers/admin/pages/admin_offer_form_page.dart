import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/presentation/features/products/providers/product_providers.dart';
import '../../providers/offer_providers.dart';
import '../widgets/offer_form_widget.dart';

final _pickedImagePathProvider = StateProvider<String?>((ref) => null);

class AdminOfferFormPage extends ConsumerWidget {
  final String? editId;

  const AdminOfferFormPage({super.key, this.editId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(offerFormProvider(editId));
    final isEdit = editId != null;

    final productsState = ref.watch(productListProvider);
    final products = productsState.products;

    final pickedImagePath = ref.watch(_pickedImagePathProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? context.l10n.editOffer : context.l10n.addOffer),
      ),
      body: OfferFormWidget(
        state: formState,
        products: products,
        pickedImagePath: pickedImagePath,
        onTitleArChanged: (v) => ref.read(offerFormProvider(editId).notifier).setTitleAr(v),
        onTitleEnChanged: (v) => ref.read(offerFormProvider(editId).notifier).setTitleEn(v),
        onDescriptionArChanged: (v) => ref.read(offerFormProvider(editId).notifier).setDescriptionAr(v),
        onDescriptionEnChanged: (v) => ref.read(offerFormProvider(editId).notifier).setDescriptionEn(v),
        onActiveChanged: (v) => ref.read(offerFormProvider(editId).notifier).setActive(v),
        onStartDateChanged: (v) => ref.read(offerFormProvider(editId).notifier).setStartDate(v),
        onEndDateChanged: (v) => ref.read(offerFormProvider(editId).notifier).setEndDate(v),
        onProductToggled: (productId) {
          ref.read(offerFormProvider(editId).notifier).toggleProductId(productId);
        },
        onImageSelected: (filePath) {
          ref.read(_pickedImagePathProvider.notifier).state = filePath;
        },
        onSubmit: () async {
          final imagePath = ref.read(_pickedImagePathProvider);
          final error = await ref.read(offerFormProvider(editId).notifier).submit(imagePath: imagePath);
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
    );
  }
}
