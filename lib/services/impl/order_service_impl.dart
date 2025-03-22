// lib/services/impl/order_service_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kumar_brooms/models/order.dart';
import 'package:kumar_brooms/services/order_service.dart';

class OrderServiceImpl implements OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _ordersCollection = 'orders';
  final String _trackingCollection = 'tracking';

  @override
  Future<List<MapEntry<String, int>>> getTrackingOrders() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_trackingCollection).doc('order').get();
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
      List<MapEntry<String, int>> orders = data.entries
          .map((e) => MapEntry(e.key, e.value as int))
          .toList();
      orders.sort((a, b) => a.value.compareTo(b.value));
      return orders;
    } catch (e) {
      print('Error fetching tracking orders: $e');
      return [];
    }
  }

  @override
  Future<Orders?> getOrderDetails(String orderId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_ordersCollection).doc(orderId).get();
      if (doc.exists) {
        final order = Orders.fromJson(doc.data() as Map<String, dynamic>);
        order.id = doc.id;
        return order;
      }
      return null;
    } catch (e) {
      print('Error fetching order details: $e');
      return null;
    }
  }

  @override
  Future<List<Map<String, String>>> getCustomers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('customers').get();
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'] as String? ?? 'Unknown',
              })
          .toList();
    } catch (e) {
      print('Error fetching customers: $e');
      return [];
    }
  }

  Future<String> _generateOrderId() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_ordersCollection).get();
      int nextId = snapshot.docs.length + 1;
      return 'o$nextId';
    } catch (e) {
      print('Error generating order ID: $e');
      return 'o${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  @override
  Future<void> addOrder(Orders order, int priority) async {
    try {
      order.id ??= await _generateOrderId();
      await _firestore
          .collection(_ordersCollection)
          .doc(order.id)
          .set(order.toJson());
      await _firestore.collection(_trackingCollection).doc('order').set(
        {order.id!: priority},
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error adding order: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateOrderItems(String orderId, Map<String, List<int>> items) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'items': items,
      });
    } catch (e) {
      print('Error updating order items: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).delete();
      await _firestore.collection(_trackingCollection).doc('order').update({
        orderId: FieldValue.delete(),
      });
    } catch (e) {
      print('Error deleting order: $e');
      rethrow;
    }
  }

  @override
  Future<void> moveOrderToWork(String orderId, int priority) async {
    try {
      // Remove from tracking/order
      await _firestore.collection(_trackingCollection).doc('order').update({
        orderId: FieldValue.delete(),
      });
      // Add to tracking/work with priority
      await _firestore.collection(_trackingCollection).doc('work').set(
        {orderId: priority},
        SetOptions(merge: true),
      );
      // Update timestamp in orders collection
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'time_stamp.work_started': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error moving order to work: $e');
      rethrow;
    }
  }
}