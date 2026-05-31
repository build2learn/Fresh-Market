import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/image_utils.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import '../../providers/offer_form_provider.dart';
import 'offer_product_selector.dart';

class OfferFormWidget extends StatelessWidget {
  final OfferFormState state;
  final ValueChanged<String> onTitleArChanged;
  final ValueChanged<String> onTitleEnChanged;
  final ValueChanged<String>? onDescriptionArChanged;
  final ValueChanged<String>? onDescriptionEnChanged;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final ValueChanged<String>? onImageSelected;
  final VoidCallback onSubmit;
  final String? pickedImagePath;
  final List<ProductEntity> products;
  final ValueChanged<String> onProductToggled;

  const OfferFormWidget({
    super.key,
    required this.state,
    required this.onTitleArChanged,
    required this.onTitleEnChanged,
    this.onDescriptionArChanged,
    this.onDescriptionEnChanged,
    required this.onActiveChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.onImageSelected,
    required this.onSubmit,
    this.pickedImagePath,
    required this.products,
    required this.onProductToggled,
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
            decoration: InputDecoration(labelText: context.l10n.offerTitle),
            textDirection: TextDirection.rtl,
            controller: TextEditingController(text: state.titleAr),
            onChanged: onTitleArChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: '${context.l10n.offerTitle} (English)'),
            textDirection: TextDirection.ltr,
            controller: TextEditingController(text: state.titleEn),
            onChanged: onTitleEnChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: '${context.l10n.offerDescription} (Arabic)'),
            textDirection: TextDirection.rtl,
            maxLines: 3,
            controller: TextEditingController(text: state.descriptionAr ?? ''),
            onChanged: onDescriptionArChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: '${context.l10n.offerDescription} (English)'),
            textDirection: TextDirection.ltr,
            maxLines: 3,
            controller: TextEditingController(text: state.descriptionEn ?? ''),
            onChanged: onDescriptionEnChanged,
          ),
          const SizedBox(height: 16),
          _buildDateField(
            context,
            label: context.l10n.startDate,
            date: state.startDate,
            onPicked: onStartDateChanged,
          ),
          const SizedBox(height: 16),
          _buildDateField(
            context,
            label: context.l10n.endDate,
            date: state.endDate,
            onPicked: onEndDateChanged,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(state.isActive ? context.l10n.active : context.l10n.inactive),
            value: state.isActive,
            onChanged: onActiveChanged,
          ),
          const SizedBox(height: 16),
          Text(context.l10n.includeProducts, style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          OfferProductSelector(
            products: products,
            selectedProductIds: state.selectedProductIds,
            onProductToggled: onProductToggled,
          ),
          const SizedBox(height: 16),
          if (state.errorMessage != null) ...[
            Text(
              state.errorMessage!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
          ],
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

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onPicked,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          date != null
              ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
              : '',
        ),
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
