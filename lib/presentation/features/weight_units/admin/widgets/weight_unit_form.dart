import 'package:flutter/material.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../providers/weight_unit_form_provider.dart';

class WeightUnitFormWidget extends StatefulWidget {
  final WeightUnitFormState state;
  final ValueChanged<String> onNameArChanged;
  final ValueChanged<String> onNameEnChanged;
  final ValueChanged<String> onAbbrChanged;
  final VoidCallback onSubmit;

  const WeightUnitFormWidget({
    super.key,
    required this.state,
    required this.onNameArChanged,
    required this.onNameEnChanged,
    required this.onAbbrChanged,
    required this.onSubmit,
  });

  @override
  State<WeightUnitFormWidget> createState() => _WeightUnitFormWidgetState();
}

class _WeightUnitFormWidgetState extends State<WeightUnitFormWidget> {
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _abbrController;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController(text: widget.state.nameAr);
    _nameEnController = TextEditingController(text: widget.state.nameEn);
    _abbrController = TextEditingController(text: widget.state.abbr);
    _controllersInitialized = widget.state.nameAr.isNotEmpty ||
        widget.state.nameEn.isNotEmpty ||
        widget.state.isEditMode;
  }

  @override
  void didUpdateWidget(covariant WeightUnitFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controllersInitialized && widget.state.isEditMode) {
      _nameArController.text = widget.state.nameAr;
      _nameEnController.text = widget.state.nameEn;
      _abbrController.text = widget.state.abbr;
      _controllersInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _abbrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: context.l10n.categoryNameAr,
            hintText: 'e.g. كيلوغرام',
          ),
          textDirection: TextDirection.rtl,
          controller: _nameArController,
          onChanged: widget.onNameArChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: context.l10n.categoryNameEn,
            hintText: 'e.g. Kilogram',
          ),
          textDirection: TextDirection.ltr,
          controller: _nameEnController,
          onChanged: widget.onNameEnChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Abbreviation',
            hintText: 'e.g. kg',
          ),
          textDirection: TextDirection.ltr,
          controller: _abbrController,
          onChanged: widget.onAbbrChanged,
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
}
