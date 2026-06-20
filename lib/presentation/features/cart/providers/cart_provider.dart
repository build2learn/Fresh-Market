import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_market/data/providers/category_repository_provider.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/data/dto/product.dto.dart';
import 'package:fresh_market/data/models/product_model.dart';

class CartItemEntity {
  final ProductEntity product;
  final int quantity;

  const CartItemEntity({
    required this.product,
    required this.quantity,
  });

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    final productMap = ProductModel.fromEntity(product).toMap();
    productMap['id'] = product.id; // Ensure ID is saved since toMap might skip it
    return {
      'product': productMap,
      'quantity': quantity,
    };
  }

  factory CartItemEntity.fromMap(Map<String, dynamic> map) {
    final productMap = Map<String, dynamic>.from(map['product'] as Map);
    final id = productMap['id'] as String? ?? '';
    final product = ProductModel.fromDto(ProductDto.fromMap(productMap, id)).toEntity();
    return CartItemEntity(
      product: product,
      quantity: map['quantity'] as int? ?? 1,
    );
  }
}

class CartNotifier extends StateNotifier<List<CartItemEntity>> {
  static const String _cartKey = 'mock_cart_items';
  final SharedPreferences? _prefs;

  CartNotifier(this._prefs) : super([]) {
    _loadCart();
  }

  void _loadCart() {
    if (_prefs == null) return;
    try {
      final jsonStr = _prefs!.getString(_cartKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = jsonDecode(jsonStr);
        state = decoded.map((e) => CartItemEntity.fromMap(Map<String, dynamic>.from(e as Map))).toList();
      }
    } catch (e) {
      debugPrint('[CART] Failed to load cart: $e');
    }
  }

  void _saveCart() {
    if (_prefs == null) return;
    try {
      final jsonStr = jsonEncode(state.map((e) => e.toMap()).toList());
      _prefs!.setString(_cartKey, jsonStr);
    } catch (e) {
      debugPrint('[CART] Failed to save cart: $e');
    }
  }

  void addToCart(ProductEntity product, {int quantity = 1}) {
    final idx = state.indexWhere((item) => item.product.id == product.id);
    if (idx != -1) {
      final currentQty = state[idx].quantity;
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == idx) state[i].copyWith(quantity: currentQty + quantity) else state[i]
      ];
    } else {
      state = [...state, CartItemEntity(product: product, quantity: quantity)];
    }
    _saveCart();
  }

  void removeFromCart(ProductEntity product) {
    state = state.where((item) => item.product.id != product.id).toList();
    _saveCart();
  }

  void updateQuantity(ProductEntity product, int quantity) {
    if (quantity <= 0) {
      removeFromCart(product);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == product.id) item.copyWith(quantity: quantity) else item
    ];
    _saveCart();
  }

  void clear() {
    state = [];
    _saveCart();
  }

  double get totalPrice {
    return state.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  int get totalItems {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemEntity>>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  final prefs = prefsAsync.valueOrNull;
  return CartNotifier(prefs);
});
