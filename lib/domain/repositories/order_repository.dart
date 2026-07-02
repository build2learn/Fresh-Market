import 'dart:async';
import '../../core/utils/result.dart';
import '../entities/order.entity.dart';

abstract interface class OrderRepository {
  Future<Result<List<OrderEntity>>> getOrders({
    String? userId,
    String? status,
    String? searchQuery,
  });

  Stream<List<OrderEntity>> watchOrders({
    String? userId,
    String? status,
    String? searchQuery,
  });

  Stream<OrderEntity?> watchOrder(String orderId);

  Future<Result<OrderEntity>> createOrder(OrderEntity order);

  Future<Result<void>> updateOrderStatus(String orderId, String status);
}
