// lib/viewmodels/order_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:kumar_brooms/models/order.dart';
import 'package:kumar_brooms/repositorys/order_repo.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  List<MapEntry<String, int>> _trackingOrders = [];
  List<Orders> _orders = [];
  List<Map<String, String>> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  OrderViewModel(this._orderRepository);

  List<MapEntry<String, int>> get trackingOrders => _trackingOrders;
  List<Orders> get orders => _orders;
  List<Map<String, String>> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTrackingOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trackingOrders = await _orderRepository.getTrackingOrders();
      _orders = [];
      for (var entry in _trackingOrders) {
        Orders? order = await _orderRepository.getOrderDetails(entry.key);
        if (order != null) _orders.add(order);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch orders: $e';
      notifyListeners();
    }
  }

  Future<void> fetchCustomers() async {
    try {
      _customers = await _orderRepository.getCustomers();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch customers: $e';
      notifyListeners();
    }
  }

  Future<void> addOrder(Orders order, int priority) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderRepository.addOrder(order, priority);
      await fetchTrackingOrders();
    } catch (e) {
      _errorMessage = 'Failed to add order: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderItems(String orderId, Map<String, List<int>> items) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderRepository.updateOrderItems(orderId, items);
      await fetchTrackingOrders();
    } catch (e) {
      _errorMessage = 'Failed to update order: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderRepository.deleteOrder(orderId);
      await fetchTrackingOrders();
    } catch (e) {
      _errorMessage = 'Failed to delete order: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> moveOrderToWork(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderRepository.moveOrderToWork(orderId, 1); // Default priority 1
      await fetchTrackingOrders(); // Refresh the order list
    } catch (e) {
      _errorMessage = 'Failed to move order to work: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}