import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/image_utils.dart';
import '../../providers/product_form_provider.dart';

class ProductFormWidget extends StatefulWidget {
  final ProductFormState state;
  final ValueChanged<String> onNameArChanged;
  final ValueChanged<String> onNameEnChanged;
  final ValueChanged<String>? onDescriptionArChanged;
  final ValueChanged<String>? onDescriptionEnChanged;
  final ValueChanged<String> onPriceChanged;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onWeightUnitIdChanged;
  final ValueChanged<String?>? onImageSelected;
  final ValueChanged<String> onCategoryIdChanged;
  final ValueChanged<bool> onFeaturedChanged;
  final ValueChanged<bool> onAvailableChanged;
  final ValueChanged<String>? onProductTypeChanged;
  final ValueChanged<String>? onProductStatusChanged;
  final ValueChanged<String> onStockQuantityChanged;
  final ValueChanged<String> onMinStockChanged;
  final ValueChanged<String> onAlertQuantityChanged;
  final VoidCallback onSubmit;
  final List<DropdownMenuItem<String>>? categoryItems;
  final List<DropdownMenuItem<String>>? weightUnitItems;
  final List<DropdownMenuItem<String>>? productTypeItems;
  final List<DropdownMenuItem<String>>? productStatusItems;
  final String? pickedImagePath;

  const ProductFormWidget({
    super.key,
    required this.state,
    required this.onNameArChanged,
    required this.onNameEnChanged,
    this.onDescriptionArChanged,
    this.onDescriptionEnChanged,
    required this.onPriceChanged,
    required this.onWeightChanged,
    required this.onWeightUnitIdChanged,
    this.onImageSelected,
    required this.onCategoryIdChanged,
    required this.onFeaturedChanged,
    required this.onAvailableChanged,
    this.onProductTypeChanged,
    this.onProductStatusChanged,
    required this.onStockQuantityChanged,
    required this.onMinStockChanged,
    required this.onAlertQuantityChanged,
    required this.onSubmit,
    this.categoryItems,
    this.weightUnitItems,
    this.productTypeItems,
    this.productStatusItems,
    this.pickedImagePath,
  });

  @override
  State<ProductFormWidget> createState() => _ProductFormWidgetState();
}

class _ProductFormWidgetState extends State<ProductFormWidget> {
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _descArController;
  late final TextEditingController _descEnController;
  late final TextEditingController _priceController;
  late final TextEditingController _weightController;
  late final TextEditingController _stockQtyController;
  late final TextEditingController _minStockController;
  late final TextEditingController _alertQtyController;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController(text: widget.state.nameAr);
    _nameEnController = TextEditingController(text: widget.state.nameEn);
    _descArController = TextEditingController(text: widget.state.descriptionAr ?? '');
    _descEnController = TextEditingController(text: widget.state.descriptionEn ?? '');
    _priceController = TextEditingController(text: widget.state.price);
    _weightController = TextEditingController(text: widget.state.weight);
    _stockQtyController = TextEditingController(text: widget.state.stockQuantity);
    _minStockController = TextEditingController(text: widget.state.minStock);
    _alertQtyController = TextEditingController(text: widget.state.alertQuantity);
  }

  @override
  void didUpdateWidget(ProductFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.nameAr != oldWidget.state.nameAr && widget.state.nameAr != _nameArController.text) {
      _nameArController.text = widget.state.nameAr;
    }
    if (widget.state.nameEn != oldWidget.state.nameEn && widget.state.nameEn != _nameEnController.text) {
      _nameEnController.text = widget.state.nameEn;
    }
    if ((widget.state.descriptionAr ?? '') != (oldWidget.state.descriptionAr ?? '') && (widget.state.descriptionAr ?? '') != _descArController.text) {
      _descArController.text = widget.state.descriptionAr ?? '';
    }
    if ((widget.state.descriptionEn ?? '') != (oldWidget.state.descriptionEn ?? '') && (widget.state.descriptionEn ?? '') != _descEnController.text) {
      _descEnController.text = widget.state.descriptionEn ?? '';
    }
    if (widget.state.price != oldWidget.state.price && widget.state.price != _priceController.text) {
      _priceController.text = widget.state.price;
    }
    if (widget.state.weight != oldWidget.state.weight && widget.state.weight != _weightController.text) {
      _weightController.text = widget.state.weight;
    }
    if (widget.state.stockQuantity != oldWidget.state.stockQuantity && widget.state.stockQuantity != _stockQtyController.text) {
      _stockQtyController.text = widget.state.stockQuantity;
    }
    if (widget.state.minStock != oldWidget.state.minStock && widget.state.minStock != _minStockController.text) {
      _minStockController.text = widget.state.minStock;
    }
    if (widget.state.alertQuantity != oldWidget.state.alertQuantity && widget.state.alertQuantity != _alertQtyController.text) {
      _alertQtyController.text = widget.state.alertQuantity;
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _stockQtyController.dispose();
    _minStockController.dispose();
    _alertQtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.onImageSelected != null) _buildImageSection(context),
          if (widget.onImageSelected != null) const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(labelText: context.l10n.productName),
            textDirection: TextDirection.rtl,
            controller: _nameArController,
            onChanged: widget.onNameArChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: '${context.l10n.productName} (English)'),
            textDirection: TextDirection.ltr,
            controller: _nameEnController,
            onChanged: widget.onNameEnChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: '${context.l10n.productDescription} (Arabic)'),
            textDirection: TextDirection.rtl,
            maxLines: 3,
            controller: _descArController,
            onChanged: widget.onDescriptionArChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: '${context.l10n.productDescription} (English)'),
            textDirection: TextDirection.ltr,
            maxLines: 3,
            controller: _descEnController,
            onChanged: widget.onDescriptionEnChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: context.l10n.price),
                  keyboardType: TextInputType.number,
                  controller: _priceController,
                  onChanged: widget.onPriceChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: context.l10n.weight),
                  keyboardType: TextInputType.number,
                  controller: _weightController,
                  onChanged: widget.onWeightChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: widget.state.weightUnitId.isNotEmpty ? widget.state.weightUnitId : null,
            decoration: InputDecoration(labelText: context.l10n.weightUnit),
            items: widget.weightUnitItems,
            onChanged: (v) {
              if (v != null) widget.onWeightUnitIdChanged(v);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: widget.state.categoryId.isNotEmpty ? widget.state.categoryId : null,
            decoration: InputDecoration(labelText: context.l10n.selectCategory),
            items: widget.categoryItems,
            onChanged: (v) {
              if (v != null) widget.onCategoryIdChanged(v);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: widget.state.productType.isNotEmpty ? widget.state.productType : null,
            decoration: const InputDecoration(labelText: 'Product Type / نوع المنتج'),
            items: widget.productTypeItems,
            onChanged: (v) {
              if (v != null && widget.onProductTypeChanged != null) widget.onProductTypeChanged!(v);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: widget.state.status.isNotEmpty ? widget.state.status : null,
            decoration: const InputDecoration(labelText: 'Product Status / حالة المنتج'),
            items: widget.productStatusItems,
            onChanged: (v) {
              if (v != null && widget.onProductStatusChanged != null) widget.onProductStatusChanged!(v);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Stock Quantity / كمية المخزون'),
            keyboardType: TextInputType.number,
            controller: _stockQtyController,
            onChanged: widget.onStockQuantityChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Minimum Stock / الحد الأدنى للمخزون'),
            keyboardType: TextInputType.number,
            controller: _minStockController,
            onChanged: widget.onMinStockChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(labelText: 'Alert Quantity / كمية التنبيه'),
            keyboardType: TextInputType.number,
            controller: _alertQtyController,
            onChanged: widget.onAlertQuantityChanged,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(context.l10n.featured),
            value: widget.state.isFeatured,
            onChanged: widget.onFeaturedChanged,
          ),
          SwitchListTile(
            title: Text(widget.state.isAvailable ? context.l10n.available : context.l10n.unavailable),
            value: widget.state.isAvailable,
            onChanged: widget.onAvailableChanged,
          ),
          if (widget.state.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.state.errorMessage!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: widget.state.isSubmitting ? null : widget.onSubmit,
            child: widget.state.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    // The picked path is treated as a URL on web (URL input dialog)
    // or a local path on mobile (file picker)
    final displayUrl = widget.pickedImagePath ?? widget.state.imageUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _pickImage(context),
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            child: displayUrl != null && displayUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      displayUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => _placeholder(context),
                    ),
                  )
                : _placeholder(context),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _pickImage(context),
          icon: const Icon(Icons.link),
          label: Text(kIsWeb ? 'Enter Image URL' : context.l10n.uploadImage),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 48, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(height: 8),
        Text(
          context.l10n.uploadImage,
          style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  void _pickImage(BuildContext context) {
    if (kIsWeb) {
      // On web: use URL input dialog
      _showImageUrlDialog(context);
    } else {
      // On mobile: use image picker
      showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(context.l10n.takePhoto),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final file = await ImageUtils.pickFromCamera();
                  if (file != null && widget.onImageSelected != null) {
                    widget.onImageSelected!(file.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(context.l10n.chooseFromGallery),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final file = await ImageUtils.pickFromGallery();
                  if (file != null && widget.onImageSelected != null) {
                    widget.onImageSelected!(file.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(context.l10n.cancel),
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showImageUrlDialog(BuildContext context) {
    final currentUrl = widget.pickedImagePath ?? widget.state.imageUrl ?? '';
    final ctrl = TextEditingController(text: currentUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Image URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Paste image URL',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(label: const Text('Meat'), onPressed: () => ctrl.text = 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500'),
                ActionChip(label: const Text('Chicken'), onPressed: () => ctrl.text = 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500'),
                ActionChip(label: const Text('Burger'), onPressed: () => ctrl.text = 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500'),
                ActionChip(label: const Text('Box'), onPressed: () => ctrl.text = 'https://images.unsplash.com/photo-1602470521006-aaea8b2a7939?w=500'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (widget.onImageSelected != null) widget.onImageSelected!(null);
            },
            child: const Text('Remove'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final url = ctrl.text.trim();
              if (widget.onImageSelected != null) {
                widget.onImageSelected!(url.isEmpty ? null : url);
              }
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }
}
