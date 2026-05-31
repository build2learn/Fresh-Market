import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';

class OfferProductSelector extends ConsumerWidget {
  final List<ProductEntity> products;
  final List<String> selectedProductIds;
  final ValueChanged<String> onProductToggled;

  const OfferProductSelector({
    super.key,
    required this.products,
    required this.selectedProductIds,
    required this.onProductToggled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return Center(child: Text(context.l10n.noProducts));
    }

    return Column(
      children: products.map((product) {
        final isSelected = selectedProductIds.contains(product.id);
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        return CheckboxListTile(
          title: Text(isRtl ? product.nameAr : product.nameEn),
          subtitle: Text(context.l10n.priceFormat(product.price.toStringAsFixed(2))),
          value: isSelected,
          onChanged: (_) => onProductToggled(product.id),
        );
      }).toList(),
    );
  }
}
