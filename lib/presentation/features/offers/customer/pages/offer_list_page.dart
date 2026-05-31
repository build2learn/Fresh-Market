import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/enums/request_state.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import '../../providers/offer_providers.dart';
import '../../providers/offer_list_provider.dart';
import '../widgets/offer_card.dart';

class OfferListPage extends ConsumerStatefulWidget {
  const OfferListPage({super.key});

  @override
  ConsumerState<OfferListPage> createState() => _OfferListPageState();
}

class _OfferListPageState extends ConsumerState<OfferListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(offerListProvider.notifier).startRealtimeSync();
    });
  }

  @override
  void dispose() {
    ref.read(offerListProvider.notifier).stopRealtimeSync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offerListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.offersTitle)),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, OfferListState state) {
    if (state.requestState == RequestState.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.requestState == RequestState.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage ?? context.l10n.errorGeneral),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(offerListProvider.notifier).refresh(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      );
    }
    if (state.offers.isEmpty) {
      return Center(child: Text(context.l10n.noOffers));
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(offerListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.offers.length,
        itemBuilder: (context, index) {
          final offer = state.offers[index];
          return OfferCard(
            offer: offer,
            onTap: () => context.push(RouteConstants.offerDetailPath(offer.id)),
          );
        },
      ),
    );
  }
}
