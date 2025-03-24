import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kumar_brooms/models/customer.dart';
import 'package:kumar_brooms/viewmodels/customer_viewmodel.dart';
import 'package:provider/provider.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _advanceAmountController = TextEditingController();
  final _pendingAmountController = TextEditingController();

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerViewModel>(context, listen: false)
          .fetchAllCustomers();
    });
  }

  void _showAddCustomerDialog() {
    _clearForm();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Customer',
              style: TextStyle(color: Colors.teal)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.person, color: Colors.teal),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone1Controller,
                    decoration: InputDecoration(
                      labelText: 'Phone 1',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.phone, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone2Controller,
                    decoration: InputDecoration(
                      labelText: 'Phone 2 (Optional)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.phone, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _shopAddressController,
                    decoration: InputDecoration(
                      labelText: 'Shop Address',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon:
                          const Icon(Icons.location_on, color: Colors.teal),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _shopNameController,
                    decoration: InputDecoration(
                      labelText: 'Shop Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.store, color: Colors.teal),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _advanceAmountController,
                    decoration: InputDecoration(
                      labelText: 'Advance Amount (₹)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon:
                          const Icon(Icons.currency_rupee, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty || double.tryParse(value) != null
                            ? null
                            : 'Invalid number',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pendingAmountController,
                    decoration: InputDecoration(
                      labelText: 'Pending Amount (₹)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon:
                          const Icon(Icons.currency_rupee, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty || double.tryParse(value) != null
                            ? null
                            : 'Invalid number',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final customer = Customer(
                    name: _nameController.text,
                    phone1: _phone1Controller.text,
                    phone2: _phone2Controller.text,
                    shopAddress: _shopAddressController.text,
                    shopName: _shopNameController.text,
                    advanceAmount: _advanceAmountController.text.isEmpty
                        ? 0.0
                        : double.parse(_advanceAmountController.text),
                    pendingAmount: _pendingAmountController.text.isEmpty
                        ? 0.0
                        : double.parse(_pendingAmountController.text),
                  );
                  Provider.of<CustomerViewModel>(context, listen: false)
                      .addCustomer(customer);
                  Navigator.pop(context);
                  _clearForm();
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  void _showEditCustomerDialog(Customer customer) {
    _nameController.text = customer.name;
    _phone1Controller.text = customer.phone1;
    _phone2Controller.text = customer.phone2;
    _shopAddressController.text = customer.shopAddress;
    _shopNameController.text = customer.shopName;
    _advanceAmountController.text = customer.advanceAmount.toString();
    _pendingAmountController.text = customer.pendingAmount.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title:
              const Text('Edit Customer', style: TextStyle(color: Colors.teal)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.person, color: Colors.teal),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone1Controller,
                    decoration: InputDecoration(
                      labelText: 'Phone 1',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.phone, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone2Controller,
                    decoration: InputDecoration(
                      labelText: 'Phone 2 (Optional)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.phone, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _shopAddressController,
                    decoration: InputDecoration(
                      labelText: 'Shop Address',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon:
                          const Icon(Icons.location_on, color: Colors.teal),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _shopNameController,
                    decoration: InputDecoration(
                      labelText: 'Shop Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.store, color: Colors.teal),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _advanceAmountController,
                    decoration: InputDecoration(
                      labelText: 'Advance Amount (₹)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon:
                          const Icon(Icons.currency_rupee, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty || double.tryParse(value) != null
                            ? null
                            : 'Invalid number',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pendingAmountController,
                    decoration: InputDecoration(
                      labelText: 'Pending Amount (₹)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon:
                          const Icon(Icons.currency_rupee, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty || double.tryParse(value) != null
                            ? null
                            : 'Invalid number',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final updatedCustomer = Customer(
                    id: customer.id,
                    name: _nameController.text,
                    phone1: _phone1Controller.text,
                    phone2: _phone2Controller.text,
                    shopAddress: _shopAddressController.text,
                    shopName: _shopNameController.text,
                    advanceAmount: _advanceAmountController.text.isEmpty
                        ? 0.0
                        : double.parse(_advanceAmountController.text),
                    pendingAmount: _pendingAmountController.text.isEmpty
                        ? 0.0
                        : double.parse(_pendingAmountController.text),
                    advanceLastUpdate: customer.advanceLastUpdate,
                    pendingLastUpdate: customer.pendingLastUpdate,
                  );
                  Provider.of<CustomerViewModel>(context, listen: false)
                      .updateCustomer(customer.id!, updatedCustomer);
                  Navigator.pop(context);
                  _clearForm();
                }
              },
              child: const Text('Update', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _nameController.clear();
    _phone1Controller.clear();
    _phone2Controller.clear();
    _shopAddressController.clear();
    _shopNameController.clear();
    _advanceAmountController.clear();
    _pendingAmountController.clear();
  }

  void _showCustomerDetailsDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('${customer.name} Details',
              style: const TextStyle(color: Colors.teal)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ID: ${customer.id}',
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text('Mobile: ${customer.phone1}',
                    style: const TextStyle(fontSize: 14)),
                if (customer.phone2.isNotEmpty)
                  Text('Alternate: ${customer.phone2}',
                      style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Text('Shop: ${customer.shopName}',
                    style: const TextStyle(fontSize: 14)),
                Text('Address: ${customer.shopAddress}',
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
                Text('Advance: ₹${customer.advanceAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, color: Colors.green)),
                Text(
                    'Last Updated: ${_formatTimestamp(customer.advanceLastUpdate)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Text('Pending: ₹${customer.pendingAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, color: Colors.red)),
                Text(
                    'Last Updated: ${_formatTimestamp(customer.pendingLastUpdate)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 4,
      ),
      body: SafeArea(
        child: Consumer<CustomerViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.errorMessage != null) {
              return Center(
                  child: Text(viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red)));
            } else if (viewModel.customers.isEmpty) {
              return const Center(
                  child: Text('No customers available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey)));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: viewModel.customers.length,
                itemBuilder: (context, index) {
                  final customer = viewModel.customers[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text('${customer.name}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.teal)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Shop: ${customer.shopName}',
                              style: const TextStyle(fontSize: 14)),
                          Text('Address: ${customer.shopAddress}',
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          Column(
                            children: [
                              Text(
                                  'Advance: ₹${customer.advanceAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.green)),
                              const SizedBox(width: 16),
                              Text(
                                  'Pending: ₹${customer.pendingAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
                      onTap: () => _showCustomerDetailsDialog(customer),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.teal),
                            tooltip: 'Edit',
                            onPressed: () => _showEditCustomerDialog(customer),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  title: const Text('Delete Customer',
                                      style: TextStyle(color: Colors.teal)),
                                  content: const Text(
                                      'Are you sure you want to delete this customer?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel',
                                          style: TextStyle(color: Colors.grey)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Provider.of<CustomerViewModel>(context,
                                                listen: false)
                                            .deleteCustomer(customer.id!);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        backgroundColor: Colors.teal,
        tooltip: 'Add Customer',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _shopAddressController.dispose();
    _shopNameController.dispose();
    _advanceAmountController.dispose();
    _pendingAmountController.dispose();
    super.dispose();
  }
}
