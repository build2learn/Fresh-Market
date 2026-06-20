import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/domain/entities/lookup.entity.dart';
import 'package:fresh_market/data/providers/lookup_repository_provider.dart';
import '../providers/lookup_providers.dart';
import 'package:fresh_market/core/utils/result.dart';

class LookupFormPage extends ConsumerStatefulWidget {
  final int? editId;
  final String lookupType;

  const LookupFormPage({
    super.key,
    required this.lookupType,
    this.editId,
  });

  @override
  ConsumerState<LookupFormPage> createState() => _LookupFormPageState();
}

class _LookupFormPageState extends ConsumerState<LookupFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _nameArController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _imageUrlController;
  bool _isActive = true;
  bool _isSubmitting = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _nameArController = TextEditingController();
    _nameEnController = TextEditingController();
    _imageUrlController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded && widget.editId != null) {
      _loadData();
    }
  }

  void _loadData() async {
    setState(() => _isSubmitting = true);
    final repo = ref.read(lookupRepositoryProvider);
    final result = await repo.getLookups(widget.lookupType);
    if (result is Success<List<LookupEntity>>) {
      final list = result.data;
      final item = list.cast<LookupEntity?>().firstWhere(
            (l) => l?.id == widget.editId,
            orElse: () => null,
          );
      if (item != null) {
        _codeController.text = item.code;
        _nameArController.text = item.nameAr;
        _nameEnController.text = item.nameEn;
        _imageUrlController.text = item.imageUrl ?? '';
        setState(() {
          _isActive = item.isActive;
          _loaded = true;
        });
      }
    }
    setState(() => _isSubmitting = false);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameArController.dispose();
    _nameEnController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isEdit = widget.editId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit
            ? (isRtl ? 'تعديل عنصر' : 'Edit Lookup Item')
            : (isRtl ? 'إضافة عنصر جديد' : 'Add Lookup Item')),
      ),
      body: _isSubmitting && !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Code / الكود',
                        hintText: 'e.g. fresh_meat',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameArController,
                      decoration: const InputDecoration(
                        labelText: 'Name (Arabic) / الاسم بالعربية',
                      ),
                      textDirection: TextDirection.rtl,
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameEnController,
                      decoration: const InputDecoration(
                        labelText: 'Name (English) / الاسم بالإنجليزية',
                      ),
                      textDirection: TextDirection.ltr,
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    if (widget.lookupType == 'Category') ...[
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL / رابط الصورة',
                          hintText: 'https://images.unsplash.com/...',
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SwitchListTile(
                      title: Text(isRtl ? 'نشط' : 'Is Active'),
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isRtl ? 'حفظ' : 'Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final repo = ref.read(lookupRepositoryProvider);

    final item = LookupEntity(
      id: widget.editId ?? 0,
      lookupType: widget.lookupType,
      code: _codeController.text.trim(),
      nameAr: _nameArController.text.trim(),
      nameEn: _nameEnController.text.trim(),
      isActive: _isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrl: _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : null,
    );

    final Result result;
    if (widget.editId != null) {
      result = await repo.updateLookup(item);
    } else {
      result = await repo.createLookup(item);
    }

    setState(() => _isSubmitting = false);

    if (result is Success && mounted) {
      context.showSnackBar(widget.editId != null ? 'Saved successfully!' : 'Created successfully!');
      context.pop();
    } else if (result is Failure && mounted) {
      context.showSnackBar(result.error.message, isError: true);
    }
  }
}
