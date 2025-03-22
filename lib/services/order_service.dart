// lib/services/order_service.dart
import 'package:kumar_brooms/models/order.dart';

abstract class OrderService {
  Future<List<MapEntry<String, int>>> getTrackingOrders();
  Future<List<MapEntry<String, int>>> getWorkOrders();
  Future<List<MapEntry<String, int>>> getDeliveryOrders();
  Future<List<MapEntry<String, int>>> getPaymentOrders();
  Future<List<MapEntry<String, int>>> getHistoryOrders(); // New
  Future<Orders?> getOrderDetails(String orderId);
  Future<List<Map<String, String>>> getCustomers();
  Future<void> addOrder(Orders order, int priority);
  Future<void> updateOrderItems(String orderId, Map<String, List<int>> items);
  Future<void> updateOrderPaid(String orderId, double paid);
  Future<void> deleteOrder(String orderId);
  Future<void> moveOrderToWork(String orderId, int priority);
  Future<void> moveOrderToOrder(String orderId, int priority);
  Future<void> moveOrderToDelivery(String orderId, int priority);
  Future<void> moveOrderToWorkFromDelivery(String orderId, int priority);
  Future<void> moveOrderToPayment(String orderId, int priority);
  Future<void> moveOrderToDeliveryFromPayment(String orderId, int priority);
  Future<void> moveOrderToHistory(String orderId, int priority);
}