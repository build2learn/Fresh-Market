import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/purchase_order.entity.dart';
import '../../../../data/providers/purchase_order_repository_provider.dart';

final purchaseOrdersListStreamProvider = StreamProvider.autoDispose.family<List<PurchaseOrderEntity>, Map<String, String?>>((ref, filters) {
  final repo = ref.watch(purchaseOrderRepositoryProvider);
  return repo.watchPurchaseOrders(
    supplierId: filters['supplierId'],
    status: filters['status'],
  );
});

class PurchaseOrderFormState {
  final String supplierId;
  final String supplierName;
  final String status;
  final List<PurchaseOrderItemEntity> items;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isEditMode;

  const PurchaseOrderFormState({
    this.supplierId = '',
    this.supplierName = '',
    this.status = 'Pending',
    this.items = const [],
    this.isSubmitting = false,
    this.errorMessage,
    this.isEditMode = false,
  });

  bool get isValid =>
      supplierId.isNotEmpty &&
      items.isNotEmpty &&
      items.every((item) => item.quantityOrdered > 0);

  PurchaseOrderFormState copyWith({
    String? supplierId,
    String? supplierName,
    String? status,
    List<PurchaseOrderItemEntity>? items,
    bool? isSubmitting,
    String? errorMessage,
    bool? isEditMode,
  }) {
    return PurchaseOrderFormState(
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      status: status ?? this.status,
      items: items ?? this.items,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  factory PurchaseOrderFormState.fromEntity(PurchaseOrderEntity entity) {
    return PurchaseOrderFormState(
      supplierId: entity.supplierId,
      supplierName: entity.supplierName,
      status: entity.status,
      items: entity.items,
      isEditMode: true,
    );
  }
}

class PurchaseOrderFormNotifier extends StateNotifier<PurchaseOrderFormState> {
  final Ref _ref;
  final String? _editId;

  PurchaseOrderFormNotifier(this._ref, this._editId) : super(const PurchaseOrderFormState()) {
    if (_editId != null) {
      _loadFromRepository();
    }
  }

  void setSupplier(String id, String name) {
    state = state.copyWith(supplierId: id, supplierName: name);
  }

  void setStatus(String v) => state = state.copyWith(status: v);

  void addItem(PurchaseOrderItemEntity item) {
    if (state.items.any((i) => i.productId == item.productId)) {
      return; // Already added
    }
    state = state.copyWith(items: [...state.items, item]);
  }

  void removeItem(String productId) {
    state = state.copyWith(items: state.items.where((i) => i.productId != productId).toList());
  }

  void updateItemQuantity(String productId, int qtyOrdered, int qtyReceived, [double? unitCost]) {
    state = state.copyWith(
      items: state.items.map((i) {
        if (i.productId == productId) {
          return i.copyWith(
            quantityOrdered: qtyOrdered,
            quantityReceived: qtyReceived,
            unitCost: unitCost ?? i.unitCost,
          );
        }
        return i;
      }).toList(),
    );
  }

  Future<void> _loadFromRepository() async {
    state = state.copyWith(isSubmitting: true);
    final repo = _ref.read(purchaseOrderRepositoryProvider);
    final result = await repo.getPurchaseOrders();
    if (result is Success<List<PurchaseOrderEntity>>) {
      try {
        final po = result.data.firstWhere((p) => p.id == _editId);
        state = PurchaseOrderFormState.fromEntity(po);
      } catch (e) {
        state = state.copyWith(isSubmitting: false, errorMessage: 'Purchase Order not found');
      }
    } else {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Failed to load Purchase Order');
    }
  }

  Future<String?> submit() async {
    if (!state.isValid) return 'Please fill all fields and add at least one item';
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final po = PurchaseOrderEntity(
      id: _editId ?? '',
      supplierId: state.supplierId,
      supplierName: state.supplierName,
      status: state.status,
      items: state.items,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repo = _ref.read(purchaseOrderRepositoryProvider);
    final Result result;
    if (_editId != null) {
      result = await repo.updatePurchaseOrder(po);
    } else {
      result = await repo.createPurchaseOrder(po);
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

  Future<String?> receiveItems(List<PurchaseOrderItemEntity> received) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    final repo = _ref.read(purchaseOrderRepositoryProvider);
    final result = await repo.receivePurchaseOrderItems(_editId!, received);
    state = state.copyWith(isSubmitting: false);
    if (result is Success) {
      setStatus('Received');
      return null;
    } else {
      final msg = (result as Failure).error.message;
      state = state.copyWith(errorMessage: msg);
      return msg;
    }
  }
}

final purchaseOrderFormProvider = StateNotifierProvider.family.autoDispose<
    PurchaseOrderFormNotifier, PurchaseOrderFormState, String?>((ref, editId) {
  return PurchaseOrderFormNotifier(ref, editId);
});
