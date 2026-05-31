import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/enums/request_state.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/usecases/product/delete_product.usecase.dart';
import 'package:fresh_market/domain/usecases/product/get_products.usecase.dart';
import 'package:fresh_market/domain/usecases/product/watch_products.usecase.dart';
import 'package:fresh_market/domain/usecases/product/toggle_product.usecase.dart';

class ProductListState {
  final List<ProductEntity> products;
  final RequestState requestState;
  final String? errorMessage;
  final bool isLoadingMore;

  const ProductListState({
    this.products = const [],
    this.requestState = RequestState.idle,
    this.errorMessage,
    this.isLoadingMore = false,
  });

  ProductListState copyWith({
    List<ProductEntity>? products,
    RequestState? requestState,
    String? errorMessage,
    bool? isLoadingMore,
  }) {
    return ProductListState(
      products: products ?? this.products,
      requestState: requestState ?? this.requestState,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final GetProductsUseCase _getProducts;
  final WatchProductsUseCase _watchProducts;
  final ToggleFeaturedUseCase _toggleFeatured;
  final ToggleAvailabilityUseCase _toggleAvailability;
  final DeleteProductUseCase _deleteProduct;

  StreamSubscription<List<ProductEntity>>? _realtimeSubscription;

  ProductListNotifier({
    required GetProductsUseCase getProducts,
    required WatchProductsUseCase watchProducts,
    required ToggleFeaturedUseCase toggleFeatured,
    required ToggleAvailabilityUseCase toggleAvailability,
    required DeleteProductUseCase deleteProduct,
  })  : _getProducts = getProducts,
        _watchProducts = watchProducts,
        _toggleFeatured = toggleFeatured,
        _toggleAvailability = toggleAvailability,
        _deleteProduct = deleteProduct,
        super(const ProductListState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(requestState: RequestState.loading);
    final result = await _getProducts();
    if (result is Success<List<ProductEntity>>) {
      state = state.copyWith(
        products: result.data,
        requestState: RequestState.success,
      );
    } else if (result is Failure<List<ProductEntity>>) {
      state = state.copyWith(
        requestState: RequestState.failure,
        errorMessage: result.error.message,
      );
    }
  }

  void startRealtimeSync() {
    _realtimeSubscription = _watchProducts().listen((products) {
      state = state.copyWith(
        products: products,
        requestState: RequestState.success,
      );
    });
  }

  void stopRealtimeSync() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = null;
  }

  Future<void> refresh() async {
    state = state.copyWith(requestState: RequestState.loading);
    final result = await _getProducts();
    if (result is Success<List<ProductEntity>>) {
      state = state.copyWith(
        products: result.data,
        requestState: RequestState.success,
      );
    } else if (result is Failure<List<ProductEntity>>) {
      state = state.copyWith(
        requestState: RequestState.failure,
        errorMessage: result.error.message,
      );
    }
  }

  Future<String?> toggleFeatured(String productId, bool currentValue) async {
    final result = await _toggleFeatured(productId, !currentValue);
    if (result is Success<void>) return null;
    if (result is Failure<void>) return result.error.message;
    return null;
  }

  Future<String?> toggleAvailability(String productId, bool currentValue) async {
    final result = await _toggleAvailability(productId, !currentValue);
    if (result is Success<void>) return null;
    if (result is Failure<void>) return result.error.message;
    return null;
  }

  Future<String?> deleteProduct(String productId) async {
    final result = await _deleteProduct(productId);
    if (result is Success<void>) {
      state = state.copyWith(
        products: state.products.where((p) => p.id != productId).toList(),
      );
      return null;
    }
    if (result is Failure<void>) return result.error.message;
    return null;
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}
