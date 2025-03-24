// lib/repositorys/impl/order_repo_impl.dart
import 'package:kumar_brooms/models/order.dart';
import 'package:kumar_brooms/repositorys/order_repo.dart';
import 'package:kumar_brooms/services/order_service.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderService _orderService;

  OrderRepositoryImpl(this._orderService);

  @override
  Future<List<MapEntry<String, int>>> getTrackingOrders() async {
    return await _orderService.getTrackingOrders();
  }

  @override
  Future<Orders?> getOrderDetails(String orderId) async {
    return await _orderService.getOrderDetails(orderId);
  }

  @override
  Future<List<Map<String, String>>> getCustomers() async {
    return await _orderService.getCustomers();
  }

  @override
  Future<void> addOrder(Orders order, int priority) async {
    await _orderService.addOrder(order, priority);
  }

  @override
  Future<void> updateOrderItems(String orderId, Map<String, List<int>> items) async {
    await _orderService.updateOrderItems(orderId, items);
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await _orderService.deleteOrder(orderId);
  }

  @override
  Future<void> moveOrderToWork(String orderId, int priority) async {
    await _orderService.moveOrderToWork(orderId, priority);
  }

  @override
  Future<List<MapEntry<String, int>>> getWorkOrders() async {
    return await _orderService.getWorkOrders();
  }

  @override
  Future<void> moveOrderToOrder(String orderId, int priority) async {
    await _orderService.moveOrderToOrder(orderId, priority);
  }

  @override
  Future<void> moveOrderToDelivery(String orderId, int priority) async {
    await _orderService.moveOrderToDelivery(orderId, priority);
  }

  @override
  Future<List<MapEntry<String, int>>> getDeliveryOrders() async {
    return await _orderService.getDeliveryOrders();
  }

  @override
  Future<void> moveOrderToWorkFromDelivery(String orderId, int priority) async {
    await _orderService.moveOrderToWorkFromDelivery(orderId, priority);
  }

  @override
  Future<void> moveOrderToPayment(String orderId, int priority) async {
    await _orderService.moveOrderToPayment(orderId, priority);
  }

  @override
  Future<List<MapEntry<String, int>>> getPaymentOrders() async {
    return await _orderService.getPaymentOrders();
  }

  @override
  Future<void> updateOrderPaid(String orderId, double paid) async {
    await _orderService.updateOrderPaid(orderId, paid);
  }

  @override
  Future<void> moveOrderToDeliveryFromPayment(String orderId, int priority) async {
    await _orderService.moveOrderToDeliveryFromPayment(orderId, priority);
  }

  @override
  Future<void> moveOrderToHistory(String orderId, int priority) async {
    await _orderService.moveOrderToHistory(orderId, priority);
  }
  
  @override
  Future<List<MapEntry<String, int>>> getHistoryOrders() async {
    return await _orderService.getHistoryOrders();
  }
  
  @override
Future<void> moveOrderToPaymentFromHistory(String orderId, int priority) async {
  await _orderService.moveOrderToPaymentFromHistory(orderId, priority);
}
}