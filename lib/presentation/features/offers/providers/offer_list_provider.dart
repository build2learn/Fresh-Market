import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/core/enums/request_state.dart';
import 'package:fresh_market/core/utils/result.dart';
import 'package:fresh_market/domain/entities/offer.entity.dart';
import 'package:fresh_market/domain/usecases/offer/delete_offer.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/get_offers.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/toggle_offer.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/watch_offers.usecase.dart';

class OfferListState {
  final List<OfferEntity> offers;
  final RequestState requestState;
  final String? errorMessage;

  const OfferListState({
    this.offers = const [],
    this.requestState = RequestState.idle,
    this.errorMessage,
  });

  OfferListState copyWith({
    List<OfferEntity>? offers,
    RequestState? requestState,
    String? errorMessage,
  }) {
    return OfferListState(
      offers: offers ?? this.offers,
      requestState: requestState ?? this.requestState,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class OfferListNotifier extends StateNotifier<OfferListState> {
  final GetOffersUseCase _getOffers;
  final WatchActiveOffersUseCase _watchActiveOffers;
  final ToggleActiveUseCase _toggleActive;
  final DeleteOfferUseCase _deleteOffer;

  StreamSubscription<List<OfferEntity>>? _realtimeSubscription;

  OfferListNotifier({
    required GetOffersUseCase getOffers,
    required WatchActiveOffersUseCase watchActiveOffers,
    required ToggleActiveUseCase toggleActive,
    required DeleteOfferUseCase deleteOffer,
  })  : _getOffers = getOffers,
        _watchActiveOffers = watchActiveOffers,
        _toggleActive = toggleActive,
        _deleteOffer = deleteOffer,
        super(const OfferListState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(requestState: RequestState.loading);
    final result = await _getOffers();
    if (result is Success<List<OfferEntity>>) {
      state = state.copyWith(
        offers: result.data,
        requestState: RequestState.success,
      );
    } else if (result is Failure<List<OfferEntity>>) {
      state = state.copyWith(
        requestState: RequestState.failure,
        errorMessage: result.error.message,
      );
    }
  }

  void startRealtimeSync() {
    _realtimeSubscription = _watchActiveOffers().listen((offers) {
      state = state.copyWith(
        offers: offers,
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
    final result = await _getOffers();
    if (result is Success<List<OfferEntity>>) {
      state = state.copyWith(
        offers: result.data,
        requestState: RequestState.success,
      );
    } else if (result is Failure<List<OfferEntity>>) {
      state = state.copyWith(
        requestState: RequestState.failure,
        errorMessage: result.error.message,
      );
    }
  }

  Future<String?> toggleActive(String offerId, bool currentValue) async {
    final result = await _toggleActive(offerId, !currentValue);
    if (result is Success<void>) return null;
    if (result is Failure<void>) return result.error.message;
    return null;
  }

  Future<String?> deleteOffer(String offerId) async {
    final result = await _deleteOffer(offerId);
    if (result is Success<void>) {
      state = state.copyWith(
        offers: state.offers.where((o) => o.id != offerId).toList(),
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
