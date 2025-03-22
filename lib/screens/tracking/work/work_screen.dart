// lib/screens/tracking/work/work_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kumar_brooms/models/item.dart';
import 'package:kumar_brooms/models/order.dart';
import 'package:kumar_brooms/viewmodels/item_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/order_viewmodel.dart';
import 'package:provider/provider.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderViewModel>(context, listen: false).fetchWorkOrders();
      Provider.of<ItemViewModel>(context, listen: false).fetchAllItems();
    });
  }

  void _showEditCompletedDialog(BuildContext context, Orders order,
      String itemId, int currentOrdered, int currentDone) {
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
    Map<String, List<int>> updatedItems = Map.from(order.items);
    double newDone = currentDone.toDouble();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Completed Pieces'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ordered: $currentOrdered'),
                  Slider(
                    value: newDone,
                    min: 0,
                    max: currentOrdered.toDouble(),
                    divisions: currentOrdered,
                    label: newDone.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        newDone = value;
                      });
                    },
                  ),
                  Text('Completed: ${newDone.round()}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (newDone.round() != currentDone) {
                      // Save if changed
                      updatedItems[itemId] = [currentOrdered, newDone.round()];
                      orderVM.updateOrderItems(order.id!, updatedItems);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
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
          } else if (orderVM.workOrdersList.isEmpty) {
            return const Center(child: Text('No work orders available.'));
          } else {
            return ListView.builder(
              itemCount: orderVM.workOrdersList.length,
              itemBuilder: (context, index) {
                final order = orderVM.workOrdersList[index];
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
                                  GestureDetector(
                                    onTap: () => _showEditCompletedDialog(
                                      context,
                                      order,
                                      e.key,
                                      e.value[0],
                                      e.value[1],
                                    ),
                                    child: Text(
                                      e.value[1].toString(),
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline),
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
                              tooltip: 'Move to Order',
                              onPressed: () {
                                orderVM.moveOrderToOrder(order.id!);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              tooltip: 'Move to Delivery',
                              onPressed: () {
                                orderVM.moveOrderToDelivery(order.id!);
                              },
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
