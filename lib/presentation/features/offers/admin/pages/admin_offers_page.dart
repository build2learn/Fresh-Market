import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fresh_market/core/constants/route_constants.dart';
import 'package:fresh_market/core/enums/request_state.dart';
import 'package:fresh_market/core/extensions/context_extensions.dart';
import '../../providers/offer_providers.dart';
import '../../providers/offer_list_provider.dart';
import '../widgets/offer_card.dart';

class AdminOffersPage extends ConsumerStatefulWidget {
  const AdminOffersPage({super.key});

  @override
  ConsumerState<AdminOffersPage> createState() => _AdminOffersPageState();
}

class _AdminOffersPageState extends ConsumerState<AdminOffersPage> {
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
      appBar: AppBar(
        title: Text(context.l10n.offersTitle),
        actions: [
          if (state.requestState == RequestState.failure)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(offerListProvider.notifier).refresh(),
            ),
        ],
      ),
      body: _buildBody(context, state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteConstants.adminOfferNew),
        child: const Icon(Icons.add),
      ),
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
            onEdit: () => context.push(RouteConstants.adminOfferEditPath(offer.id)),
            onToggleActive: () async {
              final error = await ref.read(offerListProvider.notifier).toggleActive(
                offer.id,
                offer.isActive,
              );
              if (error != null && context.mounted) {
                context.showSnackBar(error, isError: true);
              }
            },
            onDelete: () => _confirmDelete(context, offer.id),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String offerId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteOffer),
        content: Text(context.l10n.confirmDeleteOffer),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final error = await ref.read(offerListProvider.notifier).deleteOffer(offerId);
              if (error == null && context.mounted) {
                context.showSnackBar(context.l10n.itemDeleted);
              } else if (error != null && context.mounted) {
                context.showSnackBar(error, isError: true);
              }
            },
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }
}
