// lib/viewmodels/order_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:kumar_brooms/models/order.dart';
import 'package:kumar_brooms/repositorys/order_repo.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  List<MapEntry<String, int>> _trackingOrders = [];
  List<Orders> _orders = [];
  List<MapEntry<String, int>> _workOrders = [];
  List<Orders> _workOrdersList = [];
  List<MapEntry<String, int>> _deliveryOrders = [];
  List<Orders> _deliveryOrdersList = [];
  List<MapEntry<String, int>> _paymentOrders = [];
  List<Orders> _paymentOrdersList = [];
  List<MapEntry<String, int>> _historyOrders = []; // New
  List<Orders> _historyOrdersList = []; // New
  List<Map<String, String>> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  OrderViewModel(this._orderRepository);

  List<MapEntry<String, int>> get trackingOrders => _trackingOrders;
  List<Orders> get orders => _orders;
  List<MapEntry<String, int>> get workOrders => _workOrders;
  List<Orders> get workOrdersList => _workOrdersList;
  List<MapEntry<String, int>> get deliveryOrders => _deliveryOrders;
  List<Orders> get deliveryOrdersList => _deliveryOrdersList;
  List<MapEntry<String, int>> get paymentOrders => _paymentOrders;
  List<Orders> get paymentOrdersList => _paymentOrdersList;
  List<MapEntry<String, int>> get historyOrders => _historyOrders; // New
  List<Orders> get historyOrdersList => _historyOrdersList; // New
  List<Map<String, String>> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWorkOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _workOrders = await _orderRepository.getWorkOrders();
      _workOrdersList = [];
      for (var entry in _workOrders) {
        Orders? order = await _orderRepository.getOrderDetails(entry.key);
        if (order != null) _workOrdersList.add(order);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch work orders: $e';
      notifyListeners();
    }
  }

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

  Future<void> updateOrderItems(
      String orderId, Map<String, List<int>> items) async {
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

  Future<void> moveOrderToOrder(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderRepository.moveOrderToOrder(orderId, 1);
      await fetchWorkOrders();
    } catch (e) {
      _errorMessage = 'Failed to move order to order: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> moveOrderToDelivery(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderRepository.moveOrderToDelivery(orderId, 1);
      await fetchWorkOrders();
    } catch (e) {
      _errorMessage = 'Failed to move order to delivery: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDeliveryOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _deliveryOrders = await _orderRepository.getDeliveryOrders();
      _deliveryOrdersList = [];
      for (var entry in _deliveryOrders) {
        Orders? order = await _orderRepository.getOrderDetails(entry.key);
        if (order != null) _deliveryOrdersList.add(order);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch delivery orders: $e';
      notifyListeners();
    }
  }

  Future<void> moveOrderToWorkFromDelivery(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderRepository.moveOrderToWorkFromDelivery(orderId, 1);
      await fetchDeliveryOrders();
    } catch (e) {
      _errorMessage = 'Failed to move order to work: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> moveOrderToPayment(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderRepository.moveOrderToPayment(orderId, 1);
      await fetchDeliveryOrders();
    } catch (e) {
      _errorMessage = 'Failed to move order to payment: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPaymentOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _paymentOrders = await _orderRepository.getPaymentOrders();
      _paymentOrdersList = [];
      for (var entry in _paymentOrders) {
        Orders? order = await _orderRepository.getOrderDetails(entry.key);
        if (order != null) _paymentOrdersList.add(order);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch payment orders: $e';
      notifyListeners();
    }
  }

  Future<void> updateOrderPaid(String orderId, double paid) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderRepository.updateOrderPaid(orderId, paid);
      await fetchPaymentOrders();
    } catch (e) {
      _errorMessage = 'Failed to update paid amount: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> moveOrderToDeliveryFromPayment(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderRepository.moveOrderToDeliveryFromPayment(orderId, 1);
      await fetchPaymentOrders();
    } catch (e) {
      _errorMessage = 'Failed to move order to delivery: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> moveOrderToHistory(String orderId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderRepository.moveOrderToHistory(orderId, 1);
      await fetchPaymentOrders();
    } catch (e) {
      _errorMessage = 'Failed to move order to history: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistoryOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _historyOrders = await _orderRepository.getHistoryOrders();
      _historyOrdersList = [];
      for (var entry in _historyOrders) {
        Orders? order = await _orderRepository.getOrderDetails(entry.key);
        if (order != null) _historyOrdersList.add(order);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch history orders: $e';
      notifyListeners();
    }
  }

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await fetchTrackingOrders();
      await fetchWorkOrders();
      await fetchDeliveryOrders();
      await fetchPaymentOrders();
      await fetchHistoryOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch all orders: $e';
      notifyListeners();
    }
  }
  
  Future<void> moveOrderToPaymentFromHistory(String orderId) async {
  _isLoading = true;
  notifyListeners();
  try {
    await _orderRepository.moveOrderToPaymentFromHistory(orderId, 1);
    await fetchHistoryOrders(); // Refresh history orders
  } catch (e) {
    _errorMessage = 'Failed to move order to payment: $e';
    _isLoading = false;
    notifyListeners();
  }
}
}
