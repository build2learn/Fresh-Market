import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/address.entity.dart';
import 'package:fresh_market/data/providers/address_repository_provider.dart';
import 'package:fresh_market/presentation/features/auth/providers/auth_providers.dart';

final _addressDetailProvider = FutureProvider.family.autoDispose<AddressEntity?, String>((ref, id) async {
  final user = ref.read(currentUserProvider);
  if (user == null) return null;
  final result = await ref.read(addressRepositoryProvider).getAddresses(user.id);
  if (result is Success<List<AddressEntity>>) {
    try {
      return result.data.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
  return null;
});

class AddressFormPage extends ConsumerStatefulWidget {
  final String? editId;

  const AddressFormPage({
    super.key,
    this.editId,
  });

  @override
  ConsumerState<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends ConsumerState<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initFields(AddressEntity address) {
    if (_isInitialized) return;
    _nameController.text = address.name;
    _phoneController.text = address.phone;
    _addressController.text = address.address;
    _cityController.text = address.city;
    _notesController.text = address.notes ?? '';
    _isInitialized = true;
  }

  Future<void> _handleSave(AddressEntity? existingAddress) async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    final address = AddressEntity(
      id: widget.editId ?? '',
      userId: user.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      createdAt: existingAddress?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repository = ref.read(addressRepositoryProvider);
    final Result<AddressEntity> result;
    if (widget.editId != null) {
      result = await repository.updateAddress(address);
    } else {
      result = await repository.createAddress(address);
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    final isAr = context.isRtl;
    if (result is Success<AddressEntity>) {
      context.showSnackBar(
        widget.editId != null
            ? (isAr ? 'تم تحديث العنوان بنجاح!' : 'Address updated successfully!')
            : (isAr ? 'تم إضافة العنوان بنجاح!' : 'Address added successfully!'),
      );
      context.pop();
    } else if (result is Failure<AddressEntity>) {
      context.showSnackBar(result.error.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isRtl;

    if (widget.editId != null) {
      final addressAsync = ref.watch(_addressDetailProvider(widget.editId!));
      return Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'تعديل العنوان' : 'Edit Address'),
        ),
        body: addressAsync.when(
          data: (address) {
            if (address == null) {
              return Center(child: Text(isAr ? 'العنوان غير موجود' : 'Address not found'));
            }
            _initFields(address);
            return _buildForm(context, address);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'إضافة عنوان جديد' : 'Add New Address'),
      ),
      body: _buildForm(context, null),
    );
  }

  Widget _buildForm(BuildContext context, AddressEntity? existingAddress) {
    final isAr = context.isRtl;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: isAr ? 'اسم العنوان (مثال: المنزل، العمل)' : 'Address Label (e.g. Home, Work)',
              prefixIcon: const Icon(Icons.bookmark_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return isAr ? 'يرجى إدخال اسم العنوان' : 'Please enter address label';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: isAr ? 'رقم الهاتف' : 'Phone Number',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return isAr ? 'يرجى إدخال رقم الهاتف' : 'Please enter phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: isAr ? 'المدينة' : 'City',
              prefixIcon: const Icon(Icons.location_city_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return isAr ? 'يرجى إدخال المدينة' : 'Please enter city';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: isAr ? 'العنوان بالتفصيل (الشارع، البناية، الشقة)' : 'Address Details (Street, Building, Apartment)',
              prefixIcon: const Icon(Icons.map_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return isAr ? 'يرجى إدخال تفاصيل العنوان' : 'Please enter address details';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: isAr ? 'ملاحظات إضافية للتوصيل (اختياري)' : 'Additional Delivery Notes (Optional)',
              prefixIcon: const Icon(Icons.notes),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _isSaving ? null : () => _handleSave(existingAddress),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      isAr ? 'حفظ العنوان' : 'Save Address',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
