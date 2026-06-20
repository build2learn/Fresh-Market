import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/enums/request_state.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/data/providers/product_repository_provider.dart';
import 'package:fresh_market/domain/entities/product.entity.dart';
import 'package:fresh_market/domain/repositories/product_repository.dart';

class SearchState {
  final String query;
  final List<ProductEntity> results;
  final RequestState state;
  final String? errorMessage;

  const SearchState({
    this.query = '',
    this.results = const [],
    this.state = RequestState.idle,
    this.errorMessage,
  });

  SearchState copyWith({
    String? query,
    List<ProductEntity>? results,
    RequestState? state,
    String? errorMessage,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ProductRepository _productRepository;
  Timer? _debounceTimer;

  SearchNotifier({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(const SearchState());

  void onQueryChanged(String query) {
    state = state.copyWith(query: query);
    
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      state = state.copyWith(
        results: const [],
        state: RequestState.idle,
      );
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    state = state.copyWith(state: RequestState.loading);
    final result = await _productRepository.searchProducts(query);
    if (result is Success<List<ProductEntity>>) {
      state = state.copyWith(
        results: result.data,
        state: RequestState.success,
      );
    } else if (result is Failure<List<ProductEntity>>) {
      state = state.copyWith(
        state: RequestState.failure,
        errorMessage: result.error.message,
      );
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = const SearchState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final searchProvider = StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(productRepository: ref.watch(productRepositoryProvider));
});
