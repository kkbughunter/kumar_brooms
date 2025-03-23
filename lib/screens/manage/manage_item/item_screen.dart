import 'package:flutter/material.dart';
import 'package:kumar_brooms/models/customer.dart';
import 'package:kumar_brooms/models/item.dart';
import 'package:kumar_brooms/viewmodels/customer_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/item_viewmodel.dart';
import 'package:provider/provider.dart';

class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lengthController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _weightController = TextEditingController();
  final _searchController =
      TextEditingController(); // Controller for search field
  String? _selectedCustomerId;
  String? _filteredCustomerId; // For filtering displayed items

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemViewModel>(context, listen: false).fetchAllItems();
      Provider.of<CustomerViewModel>(context, listen: false)
          .fetchAllCustomers();
    });
  }

  void _showAddItemDialog() {
    _selectedCustomerId = null; // Reset selection for dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Item'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Consumer<CustomerViewModel>(
                    builder: (context, customerVM, child) {
                      return DropdownButtonFormField<String>(
                        value: _selectedCustomerId,
                        decoration:
                            const InputDecoration(labelText: 'Customer'),
                        items: customerVM.customers.map((customer) {
                          return DropdownMenuItem<String>(
                            value: customer.id,
                            child: Text(customer.name),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCustomerId = value),
                        validator: (value) => value == null ? 'Required' : null,
                      );
                    },
                  ),
                  TextFormField(
                    controller: _lengthController,
                    decoration: const InputDecoration(labelText: 'Length'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Weight'),
                    keyboardType: TextInputType.number,
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
                  final item = Item(
                    itemFor: _selectedCustomerId!,
                    length: _lengthController.text,
                    name: _nameController.text,
                    price: double.parse(_priceController.text),
                    weight: int.parse(_weightController.text),
                  );
                  Provider.of<ItemViewModel>(context, listen: false)
                      .addItem(item);
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

  void _showEditItemDialog(Item item) {
    _selectedCustomerId = item.itemFor;
    _lengthController.text = item.length;
    _nameController.text = item.name;
    _priceController.text = item.price.toString();
    _weightController.text = item.weight.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Consumer<CustomerViewModel>(
                    builder: (context, customerVM, child) {
                      return DropdownButtonFormField<String>(
                        value: _selectedCustomerId,
                        decoration:
                            const InputDecoration(labelText: 'Customer'),
                        items: customerVM.customers.map((customer) {
                          return DropdownMenuItem<String>(
                            value: customer.id,
                            child: Text(customer.name),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCustomerId = value),
                        validator: (value) => value == null ? 'Required' : null,
                      );
                    },
                  ),
                  TextFormField(
                    controller: _lengthController,
                    decoration: const InputDecoration(labelText: 'Length'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Weight'),
                    keyboardType: TextInputType.number,
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
                  final updatedItem = Item(
                    id: item.id,
                    itemFor: _selectedCustomerId!,
                    length: _lengthController.text,
                    name: _nameController.text,
                    price: double.parse(_priceController.text),
                    weight: int.parse(_weightController.text),
                  );
                  Provider.of<ItemViewModel>(context, listen: false)
                      .updateItem(item.id!, updatedItem);
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
    _selectedCustomerId = null;
    _lengthController.clear();
    _nameController.clear();
    _priceController.clear();
    _weightController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<CustomerViewModel>(
              builder: (context, customerVM, child) {
                return Autocomplete<Customer>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<
                          Customer>.empty(); // Show nothing when empty
                    }
                    return customerVM.customers.where((customer) {
                      return customer.name
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  displayStringForOption: (Customer customer) => customer.name,
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    _searchController.text =
                        controller.text; // Sync with external controller
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Search Customer',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _filteredCustomerId = null;
                              _searchController.clear();
                            });
                          },
                        ),
                      ),
                      onSubmitted: (value) => onFieldSubmitted(),
                    );
                  },
                  onSelected: (Customer customer) {
                    setState(() {
                      _filteredCustomerId = customer.id;
                      _searchController.text =
                          customer.name; // Update text field with selected name
                    });
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<ItemViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (viewModel.errorMessage != null) {
                  return Center(child: Text(viewModel.errorMessage!));
                } else if (viewModel.items.isEmpty) {
                  return const Center(child: Text('No items available.'));
                } else {
                  final filteredItems = _filteredCustomerId == null
                      ? viewModel.items
                      : viewModel.items
                          .where((item) => item.itemFor == _filteredCustomerId)
                          .toList();
                  if (filteredItems.isEmpty) {
                    return const Center(
                        child: Text('No items for this customer.'));
                  }
                  return ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Consumer<CustomerViewModel>(
                            builder: (context, customerVM, child) {
                              final customer = customerVM.customers.firstWhere(
                                (c) => c.id == item.itemFor,
                                orElse: () => Customer(
                                  id: item.itemFor,
                                  name: 'Unknown',
                                  phone1: '',
                                  phone2: '',
                                  shopAddress: '',
                                  shopName: '',
                                ),
                              );
                              return Text(
                                '${item.name} - ${customer.name}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              );
                            },
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Length: ${item.length}'),
                              Text('Price: \$${item.price}'),
                              Text('Weight: ${item.weight} kg'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditItemDialog(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Item'),
                                      content: const Text(
                                          'Are you sure you want to delete this item?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Provider.of<ItemViewModel>(context,
                                                    listen: false)
                                                .deleteItem(item.id!);
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _searchController.dispose(); // Dispose search controller
    super.dispose();
  }
}
