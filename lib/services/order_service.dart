// lib/services/order_service.dart
import 'package:kumar_brooms/models/order.dart';

abstract class OrderService {
  Future<List<MapEntry<String, int>>> getTrackingOrders();
  Future<Orders?> getOrderDetails(String orderId);
  Future<List<Map<String, String>>> getCustomers();
  Future<void> addOrder(Orders order, int priority);
  Future<void> updateOrderItems(String orderId, Map<String, List<int>> items);
  Future<void> deleteOrder(String orderId);
  Future<void> moveOrderToWork(String orderId, int priority); // New method
}