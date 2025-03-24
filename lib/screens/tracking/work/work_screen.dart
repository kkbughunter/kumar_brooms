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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Update Completed Pieces',
                  style: TextStyle(color: Colors.teal)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ordered: $currentOrdered',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Slider(
                    value: newDone,
                    min: 0,
                    max: currentOrdered.toDouble(),
                    divisions: currentOrdered,
                    label: newDone.round().toString(),
                    activeColor: Colors.teal,
                    onChanged: (value) {
                      setState(() {
                        newDone = value;
                      });
                    },
                  ),
                  Text('Completed: ${newDone.round()}',
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    if (newDone.round() != currentDone) {
                      updatedItems[itemId] = [currentOrdered, newDone.round()];
                      orderVM.updateOrderItems(order.id!, updatedItems);
                    }
                    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<OrderViewModel, ItemViewModel>(
          builder: (context, orderVM, itemVM, child) {
            if (orderVM.isLoading || itemVM.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (orderVM.errorMessage != null) {
              return Center(
                  child: Text(orderVM.errorMessage!,
                      style: const TextStyle(color: Colors.red)));
            } else if (orderVM.workOrdersList.isEmpty) {
              return const Center(
                  child: Text('No work orders available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey)));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
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
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: isFullyCompleted ? Colors.green[50] : Colors.white,
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          Text('${customer['name']}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 16,
                              columns: const [
                                DataColumn(
                                    label: Text('Item',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Length',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Weight',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Ordered',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Done',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
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
                                return DataRow(cells: [
                                  DataCell(Text(item.name)),
                                  DataCell(Text(item.length)),
                                  DataCell(Text('${item.weight}g')),
                                  DataCell(Text(e.value[0].toString())),
                                  DataCell(
                                    GestureDetector(
                                      onTap: () => _showEditCompletedDialog(
                                          context,
                                          order,
                                          e.key,
                                          e.value[0],
                                          e.value[1]),
                                      child: Text(
                                        e.value[1].toString(),
                                        style: const TextStyle(
                                            color: Colors.teal,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.teal),
                                tooltip: 'Move to Order',
                                onPressed: () {
                                  orderVM.moveOrderToOrder(order.id!);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward,
                                    color: Colors.teal),
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
      ),
    );
  }
}
