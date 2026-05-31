import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfferDetailPage extends ConsumerWidget {
  final String offerId;

  const OfferDetailPage({super.key, required this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Offer Detail')),
      body: Center(child: Text('Offer Detail - TODO: $offerId')),
    );
  }
}
