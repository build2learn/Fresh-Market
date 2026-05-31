import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/image_utils.dart';
import '../../providers/product_form_provider.dart';

class ProductFormWidget extends StatelessWidget {
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
  final VoidCallback onSubmit;
  final List<DropdownMenuItem<String>>? categoryItems;
  final List<DropdownMenuItem<String>>? weightUnitItems;
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
    required this.onSubmit,
    this.categoryItems,
    this.weightUnitItems,
    this.pickedImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onImageSelected != null) _buildImageSection(context),
          if (onImageSelected != null) const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(labelText: context.l10n.productName),
            textDirection: TextDirection.rtl,
            controller: TextEditingController(text: state.nameAr),
            onChanged: onNameArChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: '${context.l10n.productName} (English)'),
            textDirection: TextDirection.ltr,
            controller: TextEditingController(text: state.nameEn),
            onChanged: onNameEnChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: '${context.l10n.productDescription} (Arabic)'),
            textDirection: TextDirection.rtl,
            maxLines: 3,
            controller: TextEditingController(text: state.descriptionAr ?? ''),
            onChanged: onDescriptionArChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: '${context.l10n.productDescription} (English)'),
            textDirection: TextDirection.ltr,
            maxLines: 3,
            controller: TextEditingController(text: state.descriptionEn ?? ''),
            onChanged: onDescriptionEnChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: context.l10n.price),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: state.price),
                  onChanged: onPriceChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: context.l10n.weight),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: state.weight),
                  onChanged: onWeightChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.weightUnitId.isNotEmpty ? state.weightUnitId : null,
            decoration: InputDecoration(labelText: context.l10n.weightUnit),
            items: weightUnitItems,
            onChanged: (v) {
              if (v != null) onWeightUnitIdChanged(v);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.categoryId.isNotEmpty ? state.categoryId : null,
            decoration: InputDecoration(labelText: context.l10n.selectCategory),
            items: categoryItems,
            onChanged: (v) {
              if (v != null) onCategoryIdChanged(v);
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(context.l10n.featured),
            value: state.isFeatured,
            onChanged: onFeaturedChanged,
          ),
          SwitchListTile(
            title: Text(state.isAvailable ? context.l10n.available : context.l10n.unavailable),
            value: state.isAvailable,
            onChanged: onAvailableChanged,
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: state.isSubmitting ? null : onSubmit,
            child: state.isSubmitting
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
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colorScheme.outlineVariant),
        ),
        child: pickedImagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(pickedImagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => _placeholder(context),
                ),
              )
            : state.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      state.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => _placeholder(context),
                    ),
                  )
                : _placeholder(context),
      ),
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
                if (file != null && onImageSelected != null) {
                  onImageSelected!(file.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.chooseFromGallery),
              onTap: () async {
                Navigator.of(ctx).pop();
                final file = await ImageUtils.pickFromGallery();
                if (file != null && onImageSelected != null) {
                  onImageSelected!(file.path);
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
