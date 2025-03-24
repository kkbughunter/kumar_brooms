import 'package:cloud_firestore/cloud_firestore.dart';
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Add New Order',
                  style: TextStyle(color: Colors.teal)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Customer',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.teal),
                      ),
                      items: orderVM.customers
                          .map((c) => DropdownMenuItem(
                                value: c['id'],
                                child: Text(c['name']!,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        selectedCustomer = value;
                        selectedItem = null;
                        newItems.clear();
                      }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Item',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon:
                            const Icon(Icons.inventory, color: Colors.teal),
                      ),
                      items: filteredItems
                          .map((i) => DropdownMenuItem(
                              value: i.id, child: Text(i.name)))
                          .toList(),
                      value: selectedItem,
                      onChanged: (value) =>
                          setState(() => selectedItem = value),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon:
                            const Icon(Icons.numbers, color: Colors.teal),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add Item',
                          style: TextStyle(color: Colors.white)),
                    ),
                    if (newItems.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Selected Items: ${newItems.entries.map((e) => "${itemVM.items.firstWhere((i) => i.id == e.key).name}: ${e.value[0]}").join(", ")}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedCustomer != null && newItems.isNotEmpty) {
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
                        paid: 0.0,
                      );

                      if (advanceAmount > 0) {
                        bool? useAdvance = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Text('Use Advance?',
                                style: TextStyle(color: Colors.teal)),
                            content: Text(
                              'Customer has ₹${advanceAmount.toStringAsFixed(2)} advance.\nTotal: ₹${totalAmount.toStringAsFixed(2)}.\nApply advance?',
                              style: const TextStyle(fontSize: 16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('No',
                                    style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Yes',
                                    style: TextStyle(color: Colors.teal)),
                              ),
                            ],
                          ),
                        );

                        if (useAdvance == true) {
                          double amountToDeduct = totalAmount > advanceAmount
                              ? advanceAmount
                              : totalAmount;
                          newOrder.paid = amountToDeduct;
                          double newAdvance = advanceAmount - amountToDeduct;
                          double newPending = totalAmount - amountToDeduct;

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

                      orderVM.addOrder(newOrder, 1);
                      Navigator.pop(context);
                    }
                  },
                  child:
                      const Text('Save', style: TextStyle(color: Colors.teal)),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Update Order',
                  style: TextStyle(color: Colors.teal)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Add Item',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          prefixIcon:
                              const Icon(Icons.inventory, color: Colors.teal),
                        ),
                        items: filteredItems
                            .map((i) => DropdownMenuItem(
                                value: i.id, child: Text(i.name)))
                            .toList(),
                        value: selectedItem,
                        onChanged: (value) =>
                            setState(() => selectedItem = value),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: quantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          prefixIcon:
                              const Icon(Icons.numbers, color: Colors.teal),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Add Item',
                            style: TextStyle(color: Colors.white)),
                      ),
                      if (updatedItems.isNotEmpty) ...[
                        const SizedBox(height: 12),
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
                                      weight: 0),
                                );
                                return ListTile(
                                  title: Text(
                                      '${item.name}: ${e.value[0]} ordered'),
                                  subtitle: Text(
                                      'Length: ${item.length}, Price: ₹${item.price}, Weight: ${item.weight}g'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => setState(
                                        () => updatedItems.remove(e.key)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    orderVM.updateOrderItems(order.id!, updatedItems);
                    Navigator.pop(context);
                  },
                  child: const Text('Update',
                      style: TextStyle(color: Colors.teal)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Edit Item: ${itemVM.items.firstWhere((i) => i.id == itemId, orElse: () => Item(itemFor: '', length: 'N/A', name: itemId, price: 0.0, weight: 0)).name}',
            style: const TextStyle(color: Colors.teal),
          ),
          content: TextField(
            controller: quantityController,
            decoration: InputDecoration(
              labelText: 'Ordered Quantity',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.numbers, color: Colors.teal),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
              child: const Text('Save', style: TextStyle(color: Colors.teal)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Item: ${item.name}',
              style: const TextStyle(color: Colors.teal)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: lengthController,
                  decoration: InputDecoration(
                    labelText: 'Length',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon:
                        const Icon(Icons.straighten, color: Colors.teal),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: 'Weight (g)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon:
                        const Icon(Icons.fitness_center, color: Colors.teal),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price (₹)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon:
                        const Icon(Icons.currency_rupee, color: Colors.teal),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
              child: const Text('Save', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(Map<String, dynamic> timestamps) {
    final orderPlaced = timestamps['order_placed'] as Timestamp?;
    return orderPlaced != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(orderPlaced.toDate())
        : 'Not available';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer3<OrderViewModel, ItemViewModel, CustomerViewModel>(
          builder: (context, orderVM, itemVM, customerVM, child) {
            if (orderVM.isLoading || itemVM.isLoading || customerVM.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (orderVM.errorMessage != null) {
              return Center(
                  child: Text(orderVM.errorMessage!,
                      style: const TextStyle(color: Colors.red)));
            } else if (orderVM.orders.isEmpty) {
              return const Center(
                  child: Text('No orders available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey)));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: orderVM.orders.length,
                itemBuilder: (context, index) {
                  final order = orderVM.orders[index];
                  final customer = orderVM.customers.firstWhere(
                    (c) => c['id'] == order.customerId,
                    orElse: () => {'id': order.customerId, 'name': 'Unknown'},
                  );

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: Text('${order.id} - ${customer['name']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal)),
                          subtitle: Text(
                            'Placed: ${_formatTimestamp(order.timestamps)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columnSpacing: 16,
                                      columns: const [
                                        DataColumn(
                                            label: Text('Item',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Length',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Weight',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Price',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Ordered',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Done',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Total',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Edit',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        DataColumn(
                                            label: Text('Details',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                      ],
                                      rows: order.items.entries.map((e) {
                                        final item = itemVM.items.firstWhere(
                                          (i) => i.id == e.key,
                                          orElse: () => Item(
                                              itemFor: '',
                                              length: 'N/A',
                                              name: e.key,
                                              price: 0.0,
                                              weight: 0),
                                        );
                                        final itemTotal =
                                            item.price * e.value[0];
                                        return DataRow(cells: [
                                          DataCell(Text(item.name)),
                                          DataCell(Text(item.length)),
                                          DataCell(Text('${item.weight}g')),
                                          DataCell(Text(
                                              '₹${item.price.toStringAsFixed(2)}')),
                                          DataCell(Text(e.value[0].toString())),
                                          DataCell(Text(e.value[1].toString())),
                                          DataCell(Text(
                                              '₹${itemTotal.toStringAsFixed(2)}')),
                                          DataCell(IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.teal),
                                            onPressed: () =>
                                                _showEditItemDialog(
                                                    context,
                                                    order,
                                                    e.key,
                                                    e.value[0],
                                                    e.value[1]),
                                          )),
                                          DataCell(IconButton(
                                            icon: const Icon(
                                                Icons.edit_attributes,
                                                color: Colors.teal),
                                            onPressed: () =>
                                                _showEditItemDetailsDialog(
                                                    context, e.key),
                                          )),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Total Amount: ₹${order.items.entries.map((e) => itemVM.items.firstWhere((i) => i.id == e.key, orElse: () => Item(itemFor: '', length: 'N/A', name: e.key, price: 0.0, weight: 0)).price * e.value[0]).reduce((a, b) => a + b).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal),
                                  ),
                                  if (order.paid != null && order.paid! > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Paid: ₹${order.paid!.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.green),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.teal),
                                tooltip: 'Edit Order',
                                onPressed: () =>
                                    _showUpdateOrderDialog(context, order),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete Order',
                                onPressed: () => orderVM.deleteOrder(order.id!),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward,
                                    color: Colors.teal),
                                tooltip: 'Move to Work',
                                onPressed: () =>
                                    orderVM.moveOrderToWork(order.id!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrderDialog(context),
        backgroundColor: Colors.teal,
        tooltip: 'Add Order',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
