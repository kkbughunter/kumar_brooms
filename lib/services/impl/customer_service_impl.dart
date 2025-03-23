import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kumar_brooms/models/customer.dart';
import 'package:kumar_brooms/services/customer_service.dart';

class CustomerServiceImpl implements CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'customers';

  @override
  Future<List<Customer>> getAllCustomers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) {
        final customer = Customer.fromJson(doc.data());
        customer.id = doc.id;
        return customer;
      }).toList();
    } catch (e) {
      print('Error fetching customers: $e');
      return [];
    }
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      int nextId = snapshot.docs.length + 1;
      String customerId = 'c$nextId';

      // Set timestamps if amounts are provided
      final now = Timestamp.now();
      if (customer.advanceAmount > 0) customer.advanceLastUpdate = now;
      if (customer.pendingAmount > 0) customer.pendingLastUpdate = now;

      await _firestore.collection(_collection).doc(customerId).set(customer.toJson());
      customer.id = customerId;
    } catch (e) {
      print('Error adding customer: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateCustomer(String customerId, Customer customer) async {
    try {
      // Update timestamps if amounts change
      final existingCustomerDoc = await _firestore.collection(_collection).doc(customerId).get();
      final existingCustomer = Customer.fromJson(existingCustomerDoc.data()!);
      final now = Timestamp.now();
      if (customer.advanceAmount != existingCustomer.advanceAmount) {
        customer.advanceLastUpdate = now;
      }
      if (customer.pendingAmount != existingCustomer.pendingAmount) {
        customer.pendingLastUpdate = now;
      }

      await _firestore.collection(_collection).doc(customerId).update(customer.toJson());
    } catch (e) {
      print('Error updating customer: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firestore.collection(_collection).doc(customerId).delete();
    } catch (e) {
      print('Error deleting customer: $e');
      rethrow;
    }
  }
}