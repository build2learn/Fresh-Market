import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/lookup.entity.dart';
import '../../../../data/providers/lookup_repository_provider.dart';

final lookupListProvider = StreamProvider.family<List<LookupEntity>, String>((ref, lookupType) {
  final repository = ref.watch(lookupRepositoryProvider);
  return repository.watchLookups(lookupType);
});
