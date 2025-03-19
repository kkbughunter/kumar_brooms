import 'package:kumar_brooms/model/customer.dart';
import 'package:kumar_brooms/repositorys/customer_repo.dart';
import 'package:kumar_brooms/services/customer_service.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerService _customerService;

  CustomerRepositoryImpl(this._customerService);

  @override
  Future<List<Customer>> getAllCustomers() async {
    return await _customerService.getAllCustomers();
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    await _customerService.addCustomer(customer);
  }

  @override
  Future<void> updateCustomer(String customerId, Customer customer) async {
    await _customerService.updateCustomer(customerId, customer);
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    await _customerService.deleteCustomer(customerId);
  }
}