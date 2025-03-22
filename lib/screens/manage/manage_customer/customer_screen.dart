import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerViewModel>(context, listen: false)
          .fetchAllCustomers();
    });
  }

  void _showAddCustomerDialog() {
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
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _phone2Controller,
                    decoration: const InputDecoration(labelText: 'Phone 2'),
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
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _phone2Controller,
                    decoration: const InputDecoration(labelText: 'Phone 2'),
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
                    id: customer.id, // Preserve the original ID
                    name: _nameController.text,
                    phone1: _phone1Controller.text,
                    phone2: _phone2Controller.text,
                    shopAddress: _shopAddressController.text,
                    shopName: _shopNameController.text,
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
                    title: Text("${customer.id} -  ${customer.name}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mobile No: ${customer.phone1}'),
                        Text('Phone No: ${customer.phone2}'),
                        Text('Shop: ${customer.shopName}'),
                        Text('Address: ${customer.shopAddress}'),
                      ],
                    ),
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

  @override
  void dispose() {
    _nameController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _shopAddressController.dispose();
    _shopNameController.dispose();
    super.dispose();
  }
}
