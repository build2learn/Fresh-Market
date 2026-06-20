import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import '../../coupons/providers/coupon_providers.dart';

class AdminCouponFormPage extends ConsumerStatefulWidget {
  final String? editId;

  const AdminCouponFormPage({super.key, this.editId});

  @override
  ConsumerState<AdminCouponFormPage> createState() => _AdminCouponFormPageState();
}

class _AdminCouponFormPageState extends ConsumerState<AdminCouponFormPage> {
  late final TextEditingController _codeController;
  late final TextEditingController _discountValController;
  late final TextEditingController _minOrderController;
  late final TextEditingController _usageLimitController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    _discountValController = TextEditingController();
    _minOrderController = TextEditingController();
    _usageLimitController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountValController.dispose();
    _minOrderController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  void _syncControllers(CouponFormState state) {
    if (!_initialized && (widget.editId == null || state.code.isNotEmpty)) {
      _codeController.text = state.code;
      _discountValController.text = state.discountValue;
      _minOrderController.text = state.minOrderAmount;
      _usageLimitController.text = state.usageLimit;
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(couponFormProvider(widget.editId));
    _syncControllers(state);

    final isEdit = widget.editId != null;
    final isAr = context.isRtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? (isAr ? 'تعديل القسيمة' : 'Edit Coupon')
              : (isAr ? 'إضافة قسيمة جديدة' : 'Add New Coupon'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: isAr ? 'رمز القسيمة (مثال: SAVE10)' : 'Coupon Code (e.g. SAVE10)',
                border: const OutlineInputBorder(),
              ),
              onChanged: ref.read(couponFormProvider(widget.editId).notifier).setCode,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: state.type,
              decoration: InputDecoration(
                labelText: isAr ? 'نوع الخصم' : 'Discount Type',
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'Percentage',
                  child: Text(isAr ? 'نسبة مئوية (%)' : 'Percentage (%)'),
                ),
                DropdownMenuItem(
                  value: 'FixedAmount',
                  child: Text(isAr ? 'مبلغ ثابت' : 'Fixed Amount'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(couponFormProvider(widget.editId).notifier).setType(val);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _discountValController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: state.type == 'Percentage'
                    ? (isAr ? 'نسبة الخصم (%)' : 'Discount Percentage (%)')
                    : (isAr ? 'مبلغ الخصم' : 'Discount Value'),
                border: const OutlineInputBorder(),
              ),
              onChanged: ref.read(couponFormProvider(widget.editId).notifier).setDiscountValue,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _minOrderController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isAr ? 'الحد الأدنى لقيمة الطلب' : 'Minimum Order Amount',
                border: const OutlineInputBorder(),
              ),
              onChanged: ref.read(couponFormProvider(widget.editId).notifier).setMinOrderAmount,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usageLimitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isAr ? 'حد الاستخدام (اختياري)' : 'Usage Limit (Optional)',
                border: const OutlineInputBorder(),
              ),
              onChanged: ref.read(couponFormProvider(widget.editId).notifier).setUsageLimit,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(isAr ? 'تاريخ انتهاء الصلاحية' : 'Expiry Date'),
              subtitle: Text(
                state.expiryDate == null
                    ? (isAr ? 'لا يوجد تاريخ انتهاء' : 'No expiry date set')
                    : state.expiryDate!.toLocal().toString().split(' ')[0],
              ),
              trailing: const Icon(Icons.calendar_month_outlined),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: state.expiryDate ?? DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  ref.read(couponFormProvider(widget.editId).notifier).setExpiryDate(date);
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(isAr ? 'نشط' : 'Active'),
              value: state.isActive,
              onChanged: ref.read(couponFormProvider(widget.editId).notifier).setActive,
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: state.isSubmitting ? null : _submit,
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isAr ? 'حفظ' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final error = await ref.read(couponFormProvider(widget.editId).notifier).submit();
    if (error == null && mounted) {
      context.showSnackBar(
        widget.editId != null
            ? (context.isRtl ? 'تم حفظ التعديلات بنجاح' : 'Changes saved successfully')
            : (context.isRtl ? 'تم إنشاء القسيمة بنجاح' : 'Coupon created successfully'),
      );
      Navigator.pop(context);
    } else if (error != null && mounted) {
      context.showSnackBar(error, isError: true);
    }
  }
}
