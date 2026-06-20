import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/batch.entity.dart';
import '../../../../data/providers/batch_repository_provider.dart';

final batchesListStreamProvider = StreamProvider.autoDispose<List<BatchEntity>>((ref) {
  final repo = ref.watch(batchRepositoryProvider);
  return repo.watchBatches();
});

final batchesSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class ExpiryAlertStats {
  final List<BatchEntity> expired;
  final List<BatchEntity> expiringIn7Days;
  final List<BatchEntity> expiringIn30Days;

  const ExpiryAlertStats({
    required this.expired,
    required this.expiringIn7Days,
    required this.expiringIn30Days,
  });

  int get expiredCount => expired.length;
  int get expiringIn7DaysCount => expiringIn7Days.length;
  int get expiringIn30DaysCount => expiringIn30Days.length;
}

final expiryAlertStatsProvider = Provider.autoDispose<ExpiryAlertStats?>((ref) {
  final batchesAsync = ref.watch(batchesListStreamProvider);
  return batchesAsync.when(
    data: (list) {
      final now = DateTime.now();
      final endOf7Days = now.add(const Duration(days: 7));
      final endOf30Days = now.add(const Duration(days: 30));

      final expired = <BatchEntity>[];
      final expiring7 = <BatchEntity>[];
      final expiring30 = <BatchEntity>[];

      for (final b in list) {
        if (b.currentQuantity <= 0) continue; // Skip exhausted stock

        if (b.expiryDate.isBefore(now)) {
          expired.add(b);
        } else if (b.expiryDate.isBefore(endOf7Days)) {
          expiring7.add(b);
        } else if (b.expiryDate.isBefore(endOf30Days)) {
          expiring30.add(b);
        }
      }

      return ExpiryAlertStats(
        expired: expired,
        expiringIn7Days: expiring7,
        expiringIn30Days: expiring30,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
