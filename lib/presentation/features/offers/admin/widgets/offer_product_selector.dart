import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';

class OfferProductSelector extends ConsumerStatefulWidget {
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
  ConsumerState<OfferProductSelector> createState() =>
      _OfferProductSelectorState();
}

class _OfferProductSelectorState extends ConsumerState<OfferProductSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductEntity> get _filteredProducts {
    if (_searchQuery.isEmpty) return widget.products;
    final query = _searchQuery.toLowerCase();
    return widget.products.where((product) {
      return product.nameAr.toLowerCase().contains(query) ||
          product.nameEn.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return Center(child: Text(context.l10n.noProducts));
    }

    final filtered = _filteredProducts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: context.l10n.searchProducts,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        ...filtered.map((product) {
          final isSelected =
              widget.selectedProductIds.contains(product.id);
          final isRtl = Directionality.of(context) == TextDirection.rtl;
          return CheckboxListTile(
            title: Text(isRtl ? product.nameAr : product.nameEn),
            subtitle: Text(context.formatPrice(product.price)),
            value: isSelected,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: (_) => widget.onProductToggled(product.id),
          );
        }),
      ],
    );
  }
}
