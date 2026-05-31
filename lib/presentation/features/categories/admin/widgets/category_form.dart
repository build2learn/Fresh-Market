import 'package:flutter/material.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import '../../providers/category_form_provider.dart';

class CategoryFormWidget extends StatelessWidget {
  final CategoryFormState state;
  final ValueChanged<String> onNameArChanged;
  final ValueChanged<String> onNameEnChanged;
  final ValueChanged<bool> onVisibilityChanged;
  final ValueChanged<String?> onImageSelected;
  final VoidCallback onSubmit;

  const CategoryFormWidget({
    super.key,
    required this.state,
    required this.onNameArChanged,
    required this.onNameEnChanged,
    required this.onVisibilityChanged,
    required this.onImageSelected,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImageSection(context),
        const SizedBox(height: 24),
        TextField(
          decoration: InputDecoration(
            labelText: context.l10n.categoryNameAr,
            hintText: context.l10n.categoryNameAr,
          ),
          textDirection: TextDirection.rtl,
          controller: TextEditingController(text: state.nameAr),
          onChanged: onNameArChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: context.l10n.categoryNameEn,
            hintText: context.l10n.categoryNameEn,
          ),
          textDirection: TextDirection.ltr,
          controller: TextEditingController(text: state.nameEn),
          onChanged: onNameEnChanged,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(
            state.isVisible ? context.l10n.visible : context.l10n.hidden,
          ),
          value: state.isVisible,
          onChanged: onVisibilityChanged,
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
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colorScheme.outlineVariant),
        ),
        child: state.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  state.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(context),
                ),
              )
            : _imagePlaceholder(context),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 32, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          context.l10n.uploadImage,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
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
              onTap: () {
                Navigator.of(ctx).pop();
                onImageSelected(null);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.chooseFromGallery),
              onTap: () {
                Navigator.of(ctx).pop();
                onImageSelected(null);
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
