import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/image_utils.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import '../../providers/offer_form_provider.dart';
import 'offer_product_selector.dart';

class OfferFormWidget extends StatefulWidget {
  final OfferFormState state;
  final ValueChanged<String> onTitleArChanged;
  final ValueChanged<String> onTitleEnChanged;
  final ValueChanged<String>? onDescriptionArChanged;
  final ValueChanged<String>? onDescriptionEnChanged;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final ValueChanged<String>? onImageSelected;
  final ValueChanged<String>? onOfferTypeChanged;
  final VoidCallback onSubmit;
  final String? pickedImagePath;
  final List<ProductEntity> products;
  final ValueChanged<String> onProductToggled;
  final List<DropdownMenuItem<String>>? offerTypeItems;

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
    this.onOfferTypeChanged,
    required this.onSubmit,
    this.pickedImagePath,
    required this.products,
    required this.onProductToggled,
    this.offerTypeItems,
  });

  @override
  State<OfferFormWidget> createState() => _OfferFormWidgetState();
}

class _OfferFormWidgetState extends State<OfferFormWidget> {
  late final TextEditingController _titleArController;
  late final TextEditingController _titleEnController;
  late final TextEditingController _descriptionArController;
  late final TextEditingController _descriptionEnController;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleArController = TextEditingController(text: widget.state.titleAr);
    _titleEnController = TextEditingController(text: widget.state.titleEn);
    _descriptionArController = TextEditingController(text: widget.state.descriptionAr ?? '');
    _descriptionEnController = TextEditingController(text: widget.state.descriptionEn ?? '');
    _controllersInitialized = widget.state.titleAr.isNotEmpty ||
        widget.state.titleEn.isNotEmpty ||
        widget.state.isEditMode;
  }

  @override
  void didUpdateWidget(covariant OfferFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controllers when edit-mode data first loads from async fetch
    if (!_controllersInitialized && widget.state.isEditMode) {
      _titleArController.text = widget.state.titleAr;
      _titleEnController.text = widget.state.titleEn;
      _descriptionArController.text = widget.state.descriptionAr ?? '';
      _descriptionEnController.text = widget.state.descriptionEn ?? '';
      _controllersInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleArController.dispose();
    _titleEnController.dispose();
    _descriptionArController.dispose();
    _descriptionEnController.dispose();
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
            decoration: InputDecoration(labelText: context.l10n.offerTitle),
            textDirection: TextDirection.rtl,
            controller: _titleArController,
            onChanged: widget.onTitleArChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: '${context.l10n.offerTitle} (English)'),
            textDirection: TextDirection.ltr,
            controller: _titleEnController,
            onChanged: widget.onTitleEnChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: '${context.l10n.offerDescription} (Arabic)'),
            textDirection: TextDirection.rtl,
            maxLines: 3,
            controller: _descriptionArController,
            onChanged: widget.onDescriptionArChanged,
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: '${context.l10n.offerDescription} (English)'),
            textDirection: TextDirection.ltr,
            maxLines: 3,
            controller: _descriptionEnController,
            onChanged: widget.onDescriptionEnChanged,
          ),
          const SizedBox(height: 16),
          _buildDateField(
            context,
            label: context.l10n.startDate,
            date: widget.state.startDate,
            onPicked: widget.onStartDateChanged,
          ),
          const SizedBox(height: 16),
          _buildDateField(
            context,
            label: context.l10n.endDate,
            date: widget.state.endDate,
            onPicked: widget.onEndDateChanged,
          ),
          DropdownButtonFormField<String>(
            value: widget.state.offerType.isNotEmpty ? widget.state.offerType : null,
            decoration: const InputDecoration(labelText: 'Offer Type / نوع العرض'),
            items: widget.offerTypeItems,
            onChanged: (v) {
              if (v != null && widget.onOfferTypeChanged != null) widget.onOfferTypeChanged!(v);
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(widget.state.isActive ? context.l10n.active : context.l10n.inactive),
            value: widget.state.isActive,
            onChanged: widget.onActiveChanged,
          ),
          const SizedBox(height: 16),
          Text(context.l10n.includeProducts, style: context.textTheme.titleMedium),
          const SizedBox(height: 8),
          OfferProductSelector(
            products: widget.products,
            selectedProductIds: widget.state.selectedProductIds,
            onProductToggled: widget.onProductToggled,
          ),
          const SizedBox(height: 16),
          if (widget.state.errorMessage != null) ...[
            Text(
              widget.state.errorMessage!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
          ],
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
        child: widget.pickedImagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.pickedImagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => _placeholder(context),
                ),
              )
            : widget.state.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.state.imageUrl!,
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
