import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import '../../suppliers/providers/supplier_providers.dart';

class AdminSupplierFormPage extends ConsumerStatefulWidget {
  final String? editId;
  const AdminSupplierFormPage({super.key, this.editId});

  @override
  ConsumerState<AdminSupplierFormPage> createState() => _AdminSupplierFormPageState();
}

class _AdminSupplierFormPageState extends ConsumerState<AdminSupplierFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _contactController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplierFormProvider(widget.editId));
    final notifier = ref.read(supplierFormProvider(widget.editId).notifier);
    final isAr = context.isRtl;

    // Synchronize controllers with state once state is loaded
    ref.listen<SupplierFormState>(supplierFormProvider(widget.editId), (prev, next) {
      if (prev != null && prev.isSubmitting && !next.isSubmitting) return; // skip when submitting
      if (_nameController.text != next.name) _nameController.text = next.name;
      if (_contactController.text != next.contactPerson) _contactController.text = next.contactPerson;
      if (_phoneController.text != next.phone) _phoneController.text = next.phone;
      if (_emailController.text != next.email) _emailController.text = next.email;
      if (_addressController.text != next.address) _addressController.text = next.address;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editId == null
              ? (isAr ? 'إضافة مورد جديد' : 'Add New Supplier')
              : (isAr ? 'تعديل بيانات المورد' : 'Edit Supplier'),
        ),
      ),
      body: state.isSubmitting && widget.editId != null && state.name.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              state.errorMessage!,
                              style: TextStyle(color: context.colorScheme.onErrorContainer),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: isAr ? 'اسم الشركة / المورد' : 'Supplier / Company Name *',
                            prefixIcon: const Icon(Icons.business),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? (isAr ? 'هذا الحقل مطلوب' : 'Name is required')
                              : null,
                          onChanged: notifier.setName,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contactController,
                          decoration: InputDecoration(
                            labelText: isAr ? 'الشخص المسؤول للمتابعة' : 'Contact Person *',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? (isAr ? 'هذا الحقل مطلوب' : 'Contact person is required')
                              : null,
                          onChanged: notifier.setContactPerson,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: isAr ? 'رقم الهاتف' : 'Phone Number *',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? (isAr ? 'هذا الحقل مطلوب' : 'Phone is required')
                              : null,
                          onChanged: notifier.setPhone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: isAr ? 'البريد الإلكتروني' : 'Email Address *',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return isAr ? 'هذا الحقل مطلوب' : 'Email is required';
                            }
                            if (!val.contains('@') || !val.contains('.')) {
                              return isAr ? 'بريد إلكتروني غير صالح' : 'Invalid email';
                            }
                            return null;
                          },
                          onChanged: notifier.setEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: isAr ? 'العنوان بالتفصيل' : 'Supplier Address *',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? (isAr ? 'هذا الحقل مطلوب' : 'Address is required')
                              : null,
                          onChanged: notifier.setAddress,
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: state.isSubmitting
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final err = await notifier.submit();
                                    if (err == null && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            widget.editId == null
                                                ? (isAr ? 'تمت إضافة المورد بنجاح' : 'Supplier added successfully')
                                                : (isAr ? 'تم تعديل المورد بنجاح' : 'Supplier updated successfully'),
                                          ),
                                        ),
                                      );
                                      context.pop();
                                    }
                                  }
                                },
                          child: state.isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  widget.editId == null
                                      ? (isAr ? 'إضافة المورد' : 'Add Supplier')
                                      : (isAr ? 'حفظ التعديلات' : 'Save Changes'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
