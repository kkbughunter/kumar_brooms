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
  final _searchController = TextEditingController();
  String? _selectedCustomerId;
  String? _filteredCustomerId;

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
    _clearForm();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title:
              const Text('Add New Item', style: TextStyle(color: Colors.teal)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Consumer<CustomerViewModel>(
                    builder: (context, customerVM, child) {
                      return DropdownButtonFormField<String>(
                        value: _selectedCustomerId,
                        decoration: InputDecoration(
                          labelText: 'Customer',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.teal),
                        ),
                        items: customerVM.customers
                            .map((customer) => DropdownMenuItem<String>(
                                  value: customer.id,
                                  child: Text(customer.name,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCustomerId = value),
                        validator: (value) => value == null ? 'Required' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lengthController,
                    decoration: InputDecoration(
                      labelText: 'Length',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon:
                          const Icon(Icons.straighten, color: Colors.teal),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.label, color: Colors.teal),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price (₹)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon:
                          const Icon(Icons.currency_rupee, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty || double.tryParse(value) == null
                            ? 'Invalid price'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: 'Weight (g)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon:
                          const Icon(Icons.fitness_center, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty || int.tryParse(value) == null
                            ? 'Invalid weight'
                            : null,
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
              child: const Text('Add', style: TextStyle(color: Colors.teal)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Item', style: TextStyle(color: Colors.teal)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Consumer<CustomerViewModel>(
                    builder: (context, customerVM, child) {
                      return DropdownButtonFormField<String>(
                        value: _selectedCustomerId,
                        decoration: InputDecoration(
                          labelText: 'Customer',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.teal),
                        ),
                        items: customerVM.customers
                            .map((customer) => DropdownMenuItem<String>(
                                  value: customer.id,
                                  child: Text(customer.name,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCustomerId = value),
                        validator: (value) => value == null ? 'Required' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lengthController,
                    decoration: InputDecoration(
                      labelText: 'Length',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon:
                          const Icon(Icons.straighten, color: Colors.teal),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.label, color: Colors.teal),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price (₹)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon:
                          const Icon(Icons.currency_rupee, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty || double.tryParse(value) == null
                            ? 'Invalid price'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: 'Weight (g)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      prefixIcon:
                          const Icon(Icons.fitness_center, color: Colors.teal),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty || int.tryParse(value) == null
                            ? 'Invalid weight'
                            : null,
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
              child: const Text('Update', style: TextStyle(color: Colors.teal)),
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
        title: const Text('Items',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 4,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<CustomerViewModel>(
                builder: (context, customerVM, child) {
                  return Autocomplete<Customer>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty)
                        return customerVM.customers;
                      return customerVM.customers.where((customer) {
                        return customer.name
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    displayStringForOption: (Customer customer) =>
                        customer.name,
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                      _searchController.text = controller.text;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Search Customer',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.teal),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _filteredCustomerId = null;
                                _searchController.clear();
                                controller.clear();
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
                        _searchController.text = customer.name;
                      });
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer2<ItemViewModel, CustomerViewModel>(
                builder: (context, itemVM, customerVM, child) {
                  if (itemVM.isLoading || customerVM.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (itemVM.errorMessage != null) {
                    return Center(
                        child: Text(itemVM.errorMessage!,
                            style: const TextStyle(color: Colors.red)));
                  } else if (itemVM.items.isEmpty) {
                    return const Center(
                        child: Text('No items available.',
                            style:
                                TextStyle(fontSize: 16, color: Colors.grey)));
                  } else {
                    final filteredItems = _filteredCustomerId == null
                        ? itemVM.items
                        : itemVM.items
                            .where(
                                (item) => item.itemFor == _filteredCustomerId)
                            .toList();
                    if (filteredItems.isEmpty) {
                      return const Center(
                          child: Text('No items for this customer.',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final customer = customerVM.customers.firstWhere(
                          (c) => c.id == item.itemFor,
                          orElse: () => Customer(
                              id: item.itemFor,
                              name: 'Unknown',
                              phone1: '',
                              phone2: '',
                              shopAddress: '',
                              shopName: ''),
                        );
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text('${item.id} - ${item.name}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Customer: ${customer.name}',
                                    style: const TextStyle(fontSize: 14)),
                                Text('Length: ${item.length}',
                                    style: const TextStyle(fontSize: 14)),
                                Text('Price: ₹${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14)),
                                Text('Weight: ${item.weight}g',
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.teal),
                                  tooltip: 'Edit',
                                  onPressed: () => _showEditItemDialog(item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  tooltip: 'Delete',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        title: const Text('Delete Item',
                                            style:
                                                TextStyle(color: Colors.teal)),
                                        content: const Text(
                                            'Are you sure you want to delete this item?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel',
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Provider.of<ItemViewModel>(
                                                      context,
                                                      listen: false)
                                                  .deleteItem(item.id!);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red)),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: Colors.teal,
        tooltip: 'Add Item',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
