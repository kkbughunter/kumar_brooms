import 'package:kumar_brooms/model/customer.dart';

abstract class CustomerService {
  Future<List<Customer>> getAllCustomers();
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(String customerId, Customer customer);
  Future<void> deleteCustomer(String customerId);
}