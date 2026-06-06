import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_market/data/providers/offer_repository_provider.dart';
import 'package:fresh_market/domain/usecases/offer/create_offer.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/delete_offer.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/get_offers.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/toggle_offer.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/update_offer.usecase.dart';
import 'package:fresh_market/domain/usecases/offer/watch_offers.usecase.dart';
import 'offer_list_provider.dart';
import 'offer_form_provider.dart';

final _getOffersUseCaseProvider = Provider<GetOffersUseCase>((ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return GetOffersUseCase(repository: repo);
});

final _createOfferUseCaseProvider = Provider<CreateOfferUseCase>((ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return CreateOfferUseCase(repository: repo);
});

final _updateOfferUseCaseProvider = Provider<UpdateOfferUseCase>((ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return UpdateOfferUseCase(repository: repo);
});

final _deleteOfferUseCaseProvider = Provider<DeleteOfferUseCase>((ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return DeleteOfferUseCase(repository: repo);
});

final _toggleActiveUseCaseProvider = Provider<ToggleActiveUseCase>((ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return ToggleActiveUseCase(repository: repo);
});

final _watchActiveOffersUseCaseProvider = Provider<WatchActiveOffersUseCase>((ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return WatchActiveOffersUseCase(repository: repo);
});

final getActiveOffersUseCaseProvider = Provider<GetActiveOffersUseCase>((ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return GetActiveOffersUseCase(repository: repo);
});

final getOfferUseCaseProvider = Provider<GetOfferUseCase>((ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return GetOfferUseCase(repository: repo);
});

final getOfferProductsUseCaseProvider = Provider<GetOfferProductsUseCase>((ref) {
  final repo = ref.watch(offerRepositoryProvider);
  return GetOfferProductsUseCase(repository: repo);
});

final offerListProvider =
    StateNotifierProvider<OfferListNotifier, OfferListState>((ref) {
  return OfferListNotifier(
    getOffers: ref.watch(_getOffersUseCaseProvider),
    watchActiveOffers: ref.watch(_watchActiveOffersUseCaseProvider),
    toggleActive: ref.watch(_toggleActiveUseCaseProvider),
    deleteOffer: ref.watch(_deleteOfferUseCaseProvider),
  );
});

final offerFormProvider = StateNotifierProvider.family.autoDispose<OfferFormNotifier, OfferFormState, String?>(
  (ref, editId) {
    return OfferFormNotifier(
      createOffer: ref.watch(_createOfferUseCaseProvider),
      updateOffer: ref.watch(_updateOfferUseCaseProvider),
      editId: editId,
    );
  },
);
