import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import '../../providers/category_form_provider.dart';

class CategoryFormWidget extends StatefulWidget {
  final CategoryFormState state;
  final ValueChanged<String> onNameArChanged;
  final ValueChanged<String> onNameEnChanged;
  final ValueChanged<bool> onVisibilityChanged;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<String?> onImageSelected;
  final VoidCallback onSubmit;

  const CategoryFormWidget({
    super.key,
    required this.state,
    required this.onNameArChanged,
    required this.onNameEnChanged,
    required this.onVisibilityChanged,
    required this.onActiveChanged,
    required this.onImageSelected,
    required this.onSubmit,
  });

  @override
  State<CategoryFormWidget> createState() => _CategoryFormWidgetState();
}

class _CategoryFormWidgetState extends State<CategoryFormWidget> {
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController(text: widget.state.nameAr);
    _nameEnController = TextEditingController(text: widget.state.nameEn);
  }

  @override
  void didUpdateWidget(CategoryFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.nameAr != oldWidget.state.nameAr &&
        widget.state.nameAr != _nameArController.text) {
      _nameArController.text = widget.state.nameAr;
    }
    if (widget.state.nameEn != oldWidget.state.nameEn &&
        widget.state.nameEn != _nameEnController.text) {
      _nameEnController.text = widget.state.nameEn;
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    super.dispose();
  }

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
            border: const OutlineInputBorder(),
          ),
          textDirection: TextDirection.rtl,
          controller: _nameArController,
          onChanged: widget.onNameArChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: context.l10n.categoryNameEn,
            hintText: context.l10n.categoryNameEn,
            border: const OutlineInputBorder(),
          ),
          textDirection: TextDirection.ltr,
          controller: _nameEnController,
          onChanged: widget.onNameEnChanged,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(
            widget.state.isVisible ? context.l10n.visible : context.l10n.hidden,
          ),
          value: widget.state.isVisible,
          onChanged: widget.onVisibilityChanged,
        ),
        SwitchListTile(
          title: Text(
            widget.state.isActive ? context.l10n.active : context.l10n.inactive,
          ),
          value: widget.state.isActive,
          onChanged: widget.onActiveChanged,
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
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showImageUrlDialog(context),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            child: widget.state.imageUrl != null && widget.state.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.state.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(context),
                    ),
                  )
                : _imagePlaceholder(context),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _showImageUrlDialog(context),
          icon: const Icon(Icons.link),
          label: Text(kIsWeb
              ? 'Enter Image URL'
              : context.l10n.uploadImage),
        ),
      ],
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showImageUrlDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.state.imageUrl ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Image URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Paste image URL',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              autofocus: true,
              onSubmitted: (v) {
                Navigator.of(ctx).pop();
                widget.onImageSelected(v.trim().isEmpty ? null : v.trim());
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _quickUrl(context, 'Meat', 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500', controller),
                _quickUrl(context, 'Chicken', 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=500', controller),
                _quickUrl(context, 'Frozen', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500', controller),
                _quickUrl(context, 'Processed', 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=500', controller),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onImageSelected(null);
            },
            child: const Text('Remove Image'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final url = controller.text.trim();
              widget.onImageSelected(url.isEmpty ? null : url);
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _quickUrl(BuildContext context, String label, String url, TextEditingController ctrl) {
    return ActionChip(
      label: Text(label),
      onPressed: () => ctrl.text = url,
    );
  }
}
