import 'dart:async';
import '../../core/utils/result.dart';
import '../entities/stock_history.entity.dart';

abstract interface class StockHistoryRepository {
  Future<Result<List<StockHistoryEntity>>> getStockHistory({String? productId});
  Stream<List<StockHistoryEntity>> watchStockHistory({String? productId});
  Future<Result<void>> logStockMovement(StockHistoryEntity entry);
}
