import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting timestamps
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
  final _pendingAmountController = TextEditingController(); // New controller

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
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
          title: const Text('Add New Customer'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _phone1Controller,
                    decoration: const InputDecoration(labelText: 'Phone 1'),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _phone2Controller,
                    decoration: const InputDecoration(labelText: 'Phone 2'),
                    keyboardType: TextInputType.phone,
                  ),
                  TextFormField(
                    controller: _shopAddressController,
                    decoration:
                        const InputDecoration(labelText: 'Shop Address'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _shopNameController,
                    decoration: const InputDecoration(labelText: 'Shop Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _advanceAmountController,
                    decoration:
                        const InputDecoration(labelText: 'Advance Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return null;
                      if (double.tryParse(value) == null)
                        return 'Invalid number';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _pendingAmountController,
                    decoration:
                        const InputDecoration(labelText: 'Pending Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return null;
                      if (double.tryParse(value) == null)
                        return 'Invalid number';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
              child: const Text('Add'),
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
          title: const Text('Edit Customer'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _phone1Controller,
                    decoration: const InputDecoration(labelText: 'Phone 1'),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _phone2Controller,
                    decoration: const InputDecoration(labelText: 'Phone 2'),
                    keyboardType: TextInputType.phone,
                  ),
                  TextFormField(
                    controller: _shopAddressController,
                    decoration:
                        const InputDecoration(labelText: 'Shop Address'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _shopNameController,
                    decoration: const InputDecoration(labelText: 'Shop Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _advanceAmountController,
                    decoration:
                        const InputDecoration(labelText: 'Advance Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return null;
                      if (double.tryParse(value) == null)
                        return 'Invalid number';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _pendingAmountController,
                    decoration:
                        const InputDecoration(labelText: 'Pending Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return null;
                      if (double.tryParse(value) == null)
                        return 'Invalid number';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
                  );
                  Provider.of<CustomerViewModel>(context, listen: false)
                      .updateCustomer(customer.id!, updatedCustomer);
                  Navigator.pop(context);
                  _clearForm();
                }
              },
              child: const Text('Update'),
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

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        centerTitle: true,
      ),
      body: Consumer<CustomerViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          } else if (viewModel.customers.isEmpty) {
            return const Center(child: Text('No customers available.'));
          } else {
            return ListView.builder(
              itemCount: viewModel.customers.length,
              itemBuilder: (context, index) {
                final customer = viewModel.customers[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text("${customer.id} - ${customer.name}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address: ${customer.shopAddress}'),
                        Text(
                            'Advance: ${customer.advanceAmount.toStringAsFixed(2)}'),
                        Text(
                            'Pending: ${customer.pendingAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    onTap: () => _showCustomerDetailsDialog(customer),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditCustomerDialog(customer),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Customer'),
                                content: const Text(
                                    'Are you sure you want to delete this customer?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Provider.of<CustomerViewModel>(context,
                                              listen: false)
                                          .deleteCustomer(customer.id!);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

// New method to show full customer details
  void _showCustomerDetailsDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Details - ${customer.name}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ID: ${customer.id}'),
                Text('Mobile No: ${customer.phone1}'),
                Text('Phone No: ${customer.phone2}'),
                Text('Shop: ${customer.shopName}'),
                Text('Address: ${customer.shopAddress}'),
                Text(
                    'Advance Amount: ${customer.advanceAmount.toStringAsFixed(2)} - ${_formatTimestamp(customer.advanceLastUpdate)}'),
                Text(
                    'Pending Amount: ${customer.pendingAmount.toStringAsFixed(2)} - ${_formatTimestamp(customer.pendingLastUpdate)}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
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
