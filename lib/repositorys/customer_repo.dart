import 'package:kumar_brooms/models/customer.dart';

abstract class CustomerRepository {
  Future<List<Customer>> getAllCustomers();
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(String customerId, Customer customer);
  Future<void> deleteCustomer(String customerId);
}