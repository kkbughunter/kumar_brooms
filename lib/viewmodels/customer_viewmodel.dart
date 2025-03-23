import 'package:flutter/material.dart';
import 'package:kumar_brooms/models/customer.dart';
import 'package:kumar_brooms/repositorys/customer_repo.dart';

class CustomerViewModel extends ChangeNotifier {
  final CustomerRepository _customerRepository;
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _errorMessage;

  CustomerViewModel(this._customerRepository); // Fixed typo: removed 'delineation'

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllCustomers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _customers = await _customerRepository.getAllCustomers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch customers: $e';
      notifyListeners();
    }
  }

  Future<void> addCustomer(Customer customer) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _customerRepository.addCustomer(customer);
      await fetchAllCustomers();
    } catch (e) {
      _errorMessage = 'Failed to add customer: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCustomer(String customerId, Customer customer) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _customerRepository.updateCustomer(customerId, customer);
      await fetchAllCustomers();
    } catch (e) {
      _errorMessage = 'Failed to update customer: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _customerRepository.deleteCustomer(customerId);
      await fetchAllCustomers();
    } catch (e) {
      _errorMessage = 'Failed to delete customer: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}