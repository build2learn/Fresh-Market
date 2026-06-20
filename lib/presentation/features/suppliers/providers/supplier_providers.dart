import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/supplier.entity.dart';
import '../../../../data/providers/supplier_repository_provider.dart';
import '../../../../domain/entities/supplier_payment.entity.dart';
import '../../../../data/providers/supplier_payment_repository_provider.dart';

final suppliersListStreamProvider = StreamProvider.autoDispose<List<SupplierEntity>>((ref) {
  final repo = ref.watch(supplierRepositoryProvider);
  return repo.watchSuppliers();
});

class SupplierFormState {
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isEditMode;

  const SupplierFormState({
    this.name = '',
    this.contactPerson = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.isSubmitting = false,
    this.errorMessage,
    this.isEditMode = false,
  });

  bool get isValid =>
      name.trim().isNotEmpty &&
      contactPerson.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      address.trim().isNotEmpty;

  SupplierFormState copyWith({
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    bool? isSubmitting,
    String? errorMessage,
    bool? isEditMode,
  }) {
    return SupplierFormState(
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  factory SupplierFormState.fromEntity(SupplierEntity entity) {
    return SupplierFormState(
      name: entity.name,
      contactPerson: entity.contactPerson,
      phone: entity.phone,
      email: entity.email,
      address: entity.address,
      isEditMode: true,
    );
  }
}

class SupplierFormNotifier extends StateNotifier<SupplierFormState> {
  final Ref _ref;
  final String? _editId;

  SupplierFormNotifier(this._ref, this._editId) : super(const SupplierFormState()) {
    if (_editId != null) {
      _loadFromRepository();
    }
  }

  void setName(String v) => state = state.copyWith(name: v);
  void setContactPerson(String v) => state = state.copyWith(contactPerson: v);
  void setPhone(String v) => state = state.copyWith(phone: v);
  void setEmail(String v) => state = state.copyWith(email: v);
  void setAddress(String v) => state = state.copyWith(address: v);

  Future<void> _loadFromRepository() async {
    state = state.copyWith(isSubmitting: true);
    final repo = _ref.read(supplierRepositoryProvider);
    final result = await repo.getSuppliers();
    if (result is Success<List<SupplierEntity>>) {
      try {
        final supplier = result.data.firstWhere((s) => s.id == _editId);
        state = SupplierFormState.fromEntity(supplier);
      } catch (e) {
        state = state.copyWith(isSubmitting: false, errorMessage: 'Supplier not found');
      }
    } else {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Failed to load supplier');
    }
  }

  Future<String?> submit() async {
    if (!state.isValid) return 'Please fill all required fields correctly';
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final supplier = SupplierEntity(
      id: _editId ?? '',
      name: state.name.trim(),
      contactPerson: state.contactPerson.trim(),
      phone: state.phone.trim(),
      email: state.email.trim(),
      address: state.address.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repo = _ref.read(supplierRepositoryProvider);
    final Result result;
    if (_editId != null) {
      result = await repo.updateSupplier(supplier);
    } else {
      result = await repo.createSupplier(supplier);
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

final supplierFormProvider = StateNotifierProvider.family.autoDispose<
    SupplierFormNotifier, SupplierFormState, String?>((ref, editId) {
  return SupplierFormNotifier(ref, editId);
});

final supplierPaymentsStreamProvider = StreamProvider.autoDispose.family<List<SupplierPaymentEntity>, String?>((ref, supplierId) {
  final repo = ref.watch(supplierPaymentRepositoryProvider);
  return repo.watchPayments(supplierId: supplierId);
});

class SupplierPaymentFormState {
  final double amount;
  final String paymentMethod;
  final String referenceNumber;
  final String notes;
  final bool isSubmitting;
  final String? errorMessage;

  const SupplierPaymentFormState({
    this.amount = 0.0,
    this.paymentMethod = 'Cash',
    this.referenceNumber = '',
    this.notes = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  bool get isValid => amount > 0 && paymentMethod.isNotEmpty;

  SupplierPaymentFormState copyWith({
    double? amount,
    String? paymentMethod,
    String? referenceNumber,
    String? notes,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return SupplierPaymentFormState(
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SupplierPaymentFormNotifier extends StateNotifier<SupplierPaymentFormState> {
  final Ref _ref;
  final String _supplierId;
  final String _supplierName;

  SupplierPaymentFormNotifier(this._ref, this._supplierId, this._supplierName)
      : super(const SupplierPaymentFormState());

  void setAmount(double v) => state = state.copyWith(amount: v);
  void setPaymentMethod(String v) => state = state.copyWith(paymentMethod: v);
  void setReferenceNumber(String v) => state = state.copyWith(referenceNumber: v);
  void setNotes(String v) => state = state.copyWith(notes: v);

  Future<String?> submit() async {
    if (!state.isValid) return 'Please enter a valid amount and payment method';
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final payment = SupplierPaymentEntity(
      id: '',
      supplierId: _supplierId,
      supplierName: _supplierName,
      amount: state.amount,
      paymentDate: DateTime.now(),
      paymentMethod: state.paymentMethod,
      referenceNumber: state.referenceNumber.trim(),
      notes: state.notes.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repo = _ref.read(supplierPaymentRepositoryProvider);
    final result = await repo.createPayment(payment);

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

class SupplierPayParams {
  final String supplierId;
  final String supplierName;
  const SupplierPayParams(this.supplierId, this.supplierName);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierPayParams &&
          runtimeType == other.runtimeType &&
          supplierId == other.supplierId &&
          supplierName == other.supplierName;

  @override
  int get hashCode => supplierId.hashCode ^ supplierName.hashCode;
}

final supplierPaymentFormProvider = StateNotifierProvider.family.autoDispose<
    SupplierPaymentFormNotifier, SupplierPaymentFormState, SupplierPayParams>((ref, params) {
  return SupplierPaymentFormNotifier(ref, params.supplierId, params.supplierName);
});
