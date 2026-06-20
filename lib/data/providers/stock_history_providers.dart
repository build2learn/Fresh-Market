import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../domain/repositories/stock_history_repository.dart';
import '../repositories/stock_history_repository_impl.dart';

final stockHistoryRepositoryProvider = Provider<StockHistoryRepository>((ref) {
  return StockHistoryRepositoryImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});
