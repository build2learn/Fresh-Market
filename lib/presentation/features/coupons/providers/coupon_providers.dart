import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/coupon.entity.dart';
import '../../../../data/providers/coupon_repository_provider.dart';

final couponsListStreamProvider = StreamProvider.autoDispose<List<CouponEntity>>((ref) {
  final repo = ref.watch(couponRepositoryProvider);
  return repo.watchCoupons();
});

class CouponFormState {
  final String code;
  final String type; // 'Percentage' or 'FixedAmount'
  final String discountValue;
  final String minOrderAmount;
  final bool isActive;
  final DateTime? expiryDate;
  final String usageLimit;
  final int usedCount;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isEditMode;

  const CouponFormState({
    this.code = '',
    this.type = 'Percentage',
    this.discountValue = '',
    this.minOrderAmount = '0',
    this.isActive = true,
    this.expiryDate,
    this.usageLimit = '',
    this.usedCount = 0,
    this.isSubmitting = false,
    this.errorMessage,
    this.isEditMode = false,
  });

  bool get isValid =>
      code.trim().isNotEmpty &&
      discountValue.isNotEmpty &&
      double.tryParse(discountValue) != null &&
      double.parse(discountValue) > 0 &&
      minOrderAmount.isNotEmpty &&
      double.tryParse(minOrderAmount) != null &&
      double.parse(minOrderAmount) >= 0 &&
      (usageLimit.trim().isEmpty || (int.tryParse(usageLimit.trim()) != null && int.parse(usageLimit.trim()) >= 0));

  CouponFormState copyWith({
    String? code,
    String? type,
    String? discountValue,
    String? minOrderAmount,
    bool? isActive,
    DateTime? expiryDate,
    String? usageLimit,
    int? usedCount,
    bool? isSubmitting,
    String? errorMessage,
    bool? isEditMode,
  }) {
    return CouponFormState(
      code: code ?? this.code,
      type: type ?? this.type,
      discountValue: discountValue ?? this.discountValue,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      isActive: isActive ?? this.isActive,
      expiryDate: expiryDate ?? this.expiryDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  factory CouponFormState.fromEntity(CouponEntity entity) {
    return CouponFormState(
      code: entity.code,
      type: entity.type,
      discountValue: entity.discountValue.toString(),
      minOrderAmount: entity.minOrderAmount.toString(),
      isActive: entity.isActive,
      expiryDate: entity.expiryDate,
      usageLimit: entity.usageLimit?.toString() ?? '',
      usedCount: entity.usedCount,
      isEditMode: true,
    );
  }
}

class CouponFormNotifier extends StateNotifier<CouponFormState> {
  final Ref _ref;
  final String? _editId;

  CouponFormNotifier(this._ref, this._editId) : super(const CouponFormState()) {
    if (_editId != null) {
      _loadFromRepository();
    }
  }

  void setCode(String v) => state = state.copyWith(code: v);
  void setType(String v) => state = state.copyWith(type: v);
  void setDiscountValue(String v) => state = state.copyWith(discountValue: v);
  void setMinOrderAmount(String v) => state = state.copyWith(minOrderAmount: v);
  void setActive(bool v) => state = state.copyWith(isActive: v);
  void setExpiryDate(DateTime? v) => state = state.copyWith(expiryDate: v);
  void setUsageLimit(String v) => state = state.copyWith(usageLimit: v);

  Future<void> _loadFromRepository() async {
    state = state.copyWith(isSubmitting: true);
    final repo = _ref.read(couponRepositoryProvider);
    final result = await repo.getCoupons();
    if (result is Success<List<CouponEntity>>) {
      try {
        final coupon = result.data.firstWhere((c) => c.id == _editId);
        state = CouponFormState.fromEntity(coupon);
      } catch (e) {
        state = state.copyWith(isSubmitting: false, errorMessage: 'Coupon not found');
      }
    } else {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Failed to load coupon');
    }
  }

  Future<String?> submit() async {
    if (!state.isValid) return 'Please fill all required fields correctly';
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final parsedLimit = state.usageLimit.trim().isEmpty ? null : int.tryParse(state.usageLimit.trim());

    final coupon = CouponEntity(
      id: _editId ?? '',
      code: state.code.trim().toUpperCase(),
      type: state.type,
      discountValue: double.parse(state.discountValue),
      minOrderAmount: double.parse(state.minOrderAmount),
      isActive: state.isActive,
      expiryDate: state.expiryDate,
      usageLimit: parsedLimit,
      usedCount: state.usedCount,
    );

    final repo = _ref.read(couponRepositoryProvider);
    final Result result;
    if (_editId != null) {
      result = await repo.updateCoupon(coupon);
    } else {
      result = await repo.createCoupon(coupon);
    }

    state = state.copyWith(isSubmitting: false);
    if (result is Success) {
      return null;
    } else {
      final msg = (result as Failure).error.message;
      state = state.copyWith(errorMessage: msg);
      return msg;
    }
  }
}

final couponFormProvider = StateNotifierProvider.family.autoDispose<
    CouponFormNotifier, CouponFormState, String?>((ref, editId) {
  return CouponFormNotifier(ref, editId);
});
