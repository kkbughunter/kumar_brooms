// lib/screens/tracking/history/delivery_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kumar_brooms/models/item.dart';
import 'package:kumar_brooms/models/order.dart';
import 'package:kumar_brooms/viewmodels/item_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/order_viewmodel.dart';
import 'package:provider/provider.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderViewModel>(context, listen: false).fetchDeliveryOrders();
      Provider.of<ItemViewModel>(context, listen: false).fetchAllItems();
    });
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
                                  subtitle: Text('Done: ${e.value[1]}'),
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

  void _updateDone(BuildContext context, Orders order, String itemId,
      int currentOrdered, String newDoneText) {
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
    Map<String, List<int>> updatedItems = Map.from(order.items);
    int newDone = int.tryParse(newDoneText) ??
        updatedItems[itemId]![1]; // Fallback to current if invalid

    if (newDone >= 0 && newDone <= currentOrdered) {
      updatedItems[itemId] = [currentOrdered, newDone];
      orderVM.updateOrderItems(order.id!, updatedItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<OrderViewModel, ItemViewModel>(
        builder: (context, orderVM, itemVM, child) {
          if (orderVM.isLoading || itemVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (orderVM.errorMessage != null) {
            return Center(child: Text(orderVM.errorMessage!));
          } else if (orderVM.deliveryOrdersList.isEmpty) {
            return const Center(child: Text('No delivery orders available.'));
          } else {
            return ListView.builder(
              itemCount: orderVM.deliveryOrdersList.length,
              itemBuilder: (context, index) {
                final order = orderVM.deliveryOrdersList[index];
                final customer = orderVM.customers.firstWhere(
                  (c) => c['id'] == order.customerId,
                  orElse: () => {'id': order.customerId, 'name': 'Unknown'},
                );
                final isFullyCompleted = order.items.entries.every(
                  (e) => e.value[1] >= e.value[0],
                );

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  color: isFullyCompleted ? Colors.lightGreen[100] : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer: ${customer['name']}'),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Length')),
                              DataColumn(label: Text('Weight')),
                              DataColumn(label: Text('Ordered')),
                              DataColumn(label: Text('Done')),
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
                              return DataRow(cells: [
                                DataCell(Text(item.name)),
                                DataCell(Text(item.length)),
                                DataCell(Text(item.weight.toString())),
                                DataCell(Text(e.value[0].toString())),
                                DataCell(
                                  SizedBox(
                                    width: 60,
                                    child: TextField(
                                      controller: TextEditingController(
                                          text: e.value[1].toString()),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 0),
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      onSubmitted: (value) => _updateDone(
                                          context,
                                          order,
                                          e.key,
                                          e.value[0],
                                          value),
                                    ),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              tooltip: 'Move to Work',
                              onPressed: () {
                                orderVM.moveOrderToWorkFromDelivery(order.id!);
                              },
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Edit Order',
                                  onPressed: () =>
                                      _showUpdateOrderDialog(context, order),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  tooltip: 'Move to Payment',
                                  onPressed: () {
                                    orderVM.moveOrderToPayment(order.id!);
                                  },
                                ),
                              ],
                            ),
                          ],
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
    );
  }
}
