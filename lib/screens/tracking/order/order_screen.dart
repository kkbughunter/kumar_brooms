import 'package:cloud_firestore/cloud_firestore.dart'; // use to identify timestamp 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kumar_brooms/models/customer.dart';
import 'package:kumar_brooms/models/item.dart';
import 'package:kumar_brooms/models/order.dart';
import 'package:kumar_brooms/viewmodels/customer_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/item_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/order_viewmodel.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderViewModel>(context, listen: false).fetchTrackingOrders();
      Provider.of<OrderViewModel>(context, listen: false).fetchCustomers();
      Provider.of<ItemViewModel>(context, listen: false).fetchAllItems();
      Provider.of<CustomerViewModel>(context, listen: false)
          .fetchAllCustomers();
    });
  }

  void _showAddOrderDialog(BuildContext context) {
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
    final itemVM = Provider.of<ItemViewModel>(context, listen: false);
    final customerVM = Provider.of<CustomerViewModel>(context, listen: false);
    String? selectedCustomer;
    String? selectedItem;
    TextEditingController quantityController = TextEditingController();
    Map<String, List<int>> newItems = {};

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<Item> filteredItems = selectedCustomer != null
                ? itemVM.items
                    .where((i) => i.itemFor == selectedCustomer)
                    .toList()
                : [];

            return AlertDialog(
              title: const Text('Add New Order'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width:
                        250, // Fixed width to prevent overflow, adjust as needed
                    child: DropdownButtonFormField<String>(
                      isExpanded:
                          true, // Ensures the dropdown takes full width and wraps text
                      decoration: const InputDecoration(
                        labelText: 'Customer',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5), // Reduce padding
                      ),
                      items: orderVM.customers
                          .map((c) => DropdownMenuItem(
                                value: c['id'],
                                child: Text(
                                  c['name']!,
                                  overflow: TextOverflow
                                      .ellipsis, // Truncate long names
                                  maxLines: 1,
                                ),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        selectedCustomer = value;
                        selectedItem = null;
                        newItems.clear();
                      }),
                    ),
),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Item'),
                    items: filteredItems
                        .map((i) => DropdownMenuItem(
                              value: i.id,
                              child: Text(i.name),
                            ))
                        .toList(),
                    value: selectedItem,
                    onChanged: (value) => setState(() => selectedItem = value),
                  ),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedItem != null &&
                          quantityController.text.isNotEmpty) {
                        setState(() {
                          newItems[selectedItem!] = [
                            int.parse(quantityController.text),
                            0
                          ];
                          selectedItem = null;
                          quantityController.clear();
                        });
                      }
                    },
                    child: const Text('Add Item'),
                  ),
                  if (newItems.isNotEmpty)
                    Text(
                        'Items: ${newItems.entries.map((e) => "${e.key}: ${e.value[0]}").join(", ")}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedCustomer != null && newItems.isNotEmpty) {
                      // Calculate total order amount
                      double totalAmount = newItems.entries
                          .map((e) =>
                              itemVM.items
                                  .firstWhere((i) => i.id == e.key,
                                      orElse: () => Item(
                                          itemFor: '',
                                          length: 'N/A',
                                          name: e.key,
                                          price: 0.0,
                                          weight: 0))
                                  .price *
                              e.value[0])
                          .reduce((a, b) => a + b);

                      // Get customer data
                      final customer = customerVM.customers.firstWhere(
                        (c) => c.id == selectedCustomer,
                        orElse: () => Customer(
                            name: 'Unknown',
                            phone1: '',
                            phone2: '',
                            shopAddress: '',
                            shopName: ''),
                      );
                      double advanceAmount = customer.advanceAmount;

                      Orders newOrder = Orders(
                        customerId: selectedCustomer!,
                        items: newItems,
                        timestamps: {},
                        paid: 0.0, // Initialize paid as 0
                      );

                      if (advanceAmount > 0) {
                        bool? useAdvance = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Use Advance Amount?'),
                            content: Text(
                                'Customer has ${advanceAmount.toStringAsFixed(2)} advance. Total order amount is ${totalAmount.toStringAsFixed(2)}. Reduce advance amount to cover this order?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        );

                        if (useAdvance == true) {
                          double amountToDeduct = totalAmount > advanceAmount
                              ? advanceAmount
                              : totalAmount;
                          newOrder.paid =
                              amountToDeduct; // Update order paid amount
                          double newAdvance = advanceAmount - amountToDeduct;
                          double newPending = totalAmount - amountToDeduct;

                          // Update customer
                          final updatedCustomer = Customer(
                            id: customer.id,
                            name: customer.name,
                            phone1: customer.phone1,
                            phone2: customer.phone2,
                            shopAddress: customer.shopAddress,
                            shopName: customer.shopName,
                            advanceAmount: newAdvance,
                            pendingAmount: customer.pendingAmount + newPending,
                            advanceLastUpdate: Timestamp.now(),
                            pendingLastUpdate: newPending > 0
                                ? Timestamp.now()
                                : customer.pendingLastUpdate,
                          );
                          await customerVM.updateCustomer(
                              customer.id!, updatedCustomer);
                        }
                      }

                      // Add the order
                      orderVM.addOrder(newOrder, 1);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateOrderDialog(BuildContext context, Orders order) {
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
    final itemVM = Provider.of<ItemViewModel>(context, listen: false);
    String? selectedItem;
    TextEditingController quantityController = TextEditingController();
    Map<String, List<int>> updatedItems = Map.from(order.items);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<Item> filteredItems = itemVM.items
                .where((i) => i.itemFor == order.customerId)
                .toList();

            return AlertDialog(
              title: const Text('Update Order'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Add Item'),
                        items: filteredItems
                            .map((i) => DropdownMenuItem(
                                  value: i.id,
                                  child: Text(i.name),
                                ))
                            .toList(),
                        value: selectedItem,
                        onChanged: (value) =>
                            setState(() => selectedItem = value),
                      ),
                      TextField(
                        controller: quantityController,
                        decoration:
                            const InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedItem != null &&
                              quantityController.text.isNotEmpty) {
                            setState(() {
                              updatedItems[selectedItem!] = [
                                int.parse(quantityController.text),
                                updatedItems[selectedItem!]?[1] ?? 0
                              ];
                              selectedItem = null;
                              quantityController.clear();
                            });
                          }
                        },
                        child: const Text('Add Item'),
                      ),
                      if (updatedItems.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: SingleChildScrollView(
                            child: Column(
                              children: updatedItems.entries.map((e) {
                                final item = itemVM.items.firstWhere(
                                  (i) => i.id == e.key,
                                  orElse: () => Item(
                                    itemFor: '',
                                    length: 'N/A',
                                    name: e.key,
                                    price: 0.0,
                                    weight: 0,
                                  ),
                                );
                                return ListTile(
                                  title: Text(
                                      'Item: ${item.name}, Ordered: ${e.value[0]}'),
                                  subtitle: Text(
                                      'Length: ${item.length}, Price: ${item.price}, Weight: ${item.weight}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => setState(
                                        () => updatedItems.remove(e.key)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
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
                    orderVM.updateOrderItems(order.id!, updatedItems);
                    Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditItemDialog(BuildContext context, Orders order, String itemId,
      int currentOrdered, int currentDone) {
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
    final itemVM = Provider.of<ItemViewModel>(context, listen: false);
    TextEditingController quantityController =
        TextEditingController(text: currentOrdered.toString());
    Map<String, List<int>> updatedItems = Map.from(order.items);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              'Edit Item: ${itemVM.items.firstWhere((i) => i.id == itemId, orElse: () => Item(itemFor: '', length: 'N/A', name: itemId, price: 0.0, weight: 0)).name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                decoration:
                    const InputDecoration(labelText: 'Ordered Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (quantityController.text.isNotEmpty) {
                  updatedItems[itemId] = [
                    int.parse(quantityController.text),
                    currentDone
                  ];
                  orderVM.updateOrderItems(order.id!, updatedItems);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDetailsDialog(BuildContext context, String itemId) {
    final itemVM = Provider.of<ItemViewModel>(context, listen: false);
    final item = itemVM.items.firstWhere(
      (i) => i.id == itemId,
      orElse: () =>
          Item(itemFor: '', length: 'N/A', name: itemId, price: 0.0, weight: 0),
    );

    TextEditingController lengthController =
        TextEditingController(text: item.length);
    TextEditingController weightController =
        TextEditingController(text: item.weight.toString());
    TextEditingController priceController =
        TextEditingController(text: item.price.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Item Details: ${item.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: lengthController,
                decoration: const InputDecoration(labelText: 'Length'),
              ),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (lengthController.text.isNotEmpty &&
                    weightController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  Item updatedItem = Item(
                    id: itemId,
                    itemFor: item.itemFor,
                    length: lengthController.text,
                    name: item.name,
                    price: double.parse(priceController.text),
                    weight: int.parse(weightController.text),
                  );
                  itemVM.updateItem(itemId, updatedItem);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(Map<String, dynamic> timestamps) {
    final orderPlaced = timestamps['order_placed'] as Timestamp?;
    if (orderPlaced != null) {
      return DateFormat('dd MMM yyyy, HH:mm').format(orderPlaced.toDate());
    }
    return 'Not available';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer3<OrderViewModel, ItemViewModel, CustomerViewModel>(
        builder: (context, orderVM, itemVM, customerVM, child) {
          if (orderVM.isLoading || itemVM.isLoading || customerVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (orderVM.errorMessage != null) {
            return Center(child: Text(orderVM.errorMessage!));
          } else if (orderVM.orders.isEmpty) {
            return const Center(child: Text('No orders available.'));
          } else {
            return ListView.builder(
              itemCount: orderVM.orders.length,
              itemBuilder: (context, index) {
                final order = orderVM.orders[index];
                final customer = orderVM.customers.firstWhere(
                  (c) => c['id'] == order.customerId,
                  orElse: () => {'id': order.customerId, 'name': 'Unknown'},
                );

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ExpansionTile(
                        title: Text('Order ID: ${order.id}'),
                        subtitle: Text(
                          'Customer: ${customer['name']}\nPlaced: ${_formatTimestamp(order.timestamps)}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Name')),
                                      DataColumn(label: Text('Length')),
                                      DataColumn(label: Text('Weight')),
                                      DataColumn(label: Text('Price')),
                                      DataColumn(label: Text('Ordered')),
                                      DataColumn(label: Text('Done')),
                                      DataColumn(label: Text('Total')),
                                      DataColumn(label: Text('Edit')),
                                      DataColumn(label: Text('Edit Item')),
                                    ],
                                    rows: order.items.entries.map((e) {
                                      final item = itemVM.items.firstWhere(
                                        (i) => i.id == e.key,
                                        orElse: () => Item(
                                          itemFor: '',
                                          length: 'N/A',
                                          name: e.key,
                                          price: 0.0,
                                          weight: 0,
                                        ),
                                      );
                                      final itemTotal = item.price * e.value[0];
                                      return DataRow(cells: [
                                        DataCell(Text(item.name)),
                                        DataCell(Text(item.length)),
                                        DataCell(Text(item.weight.toString())),
                                        DataCell(Text(
                                            item.price.toStringAsFixed(2))),
                                        DataCell(Text(e.value[0].toString())),
                                        DataCell(Text(e.value[1].toString())),
                                        DataCell(
                                            Text(itemTotal.toStringAsFixed(2))),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20),
                                            onPressed: () =>
                                                _showEditItemDialog(
                                              context,
                                              order,
                                              e.key,
                                              e.value[0],
                                              e.value[1],
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(
                                                Icons.edit_attributes,
                                                size: 20),
                                            onPressed: () =>
                                                _showEditItemDetailsDialog(
                                                    context, e.key),
                                          ),
                                        ),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Total Amount: ${order.items.entries.map((e) => itemVM.items.firstWhere((i) => i.id == e.key, orElse: () => Item(itemFor: '', length: 'N/A', name: e.key, price: 0.0, weight: 0)).price * e.value[0]).reduce((a, b) => a + b).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (order.paid != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                        'Paid: ${order.paid!.toStringAsFixed(2)}'),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showUpdateOrderDialog(context, order),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              orderVM.deleteOrder(order.id!);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            tooltip: 'Move to Work',
                            onPressed: () {
                              orderVM.moveOrderToWork(order.id!);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrderDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
