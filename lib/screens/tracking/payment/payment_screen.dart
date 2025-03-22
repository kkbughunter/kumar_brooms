// lib/screens/tracking/payment/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kumar_brooms/models/item.dart';
import 'package:kumar_brooms/models/order.dart';
import 'package:kumar_brooms/viewmodels/item_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/order_viewmodel.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderViewModel>(context, listen: false).fetchPaymentOrders();
      Provider.of<ItemViewModel>(context, listen: false).fetchAllItems();
    });
  }

  void _updatePaid(BuildContext context, Orders order, String paidText) {
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
    double? newPaid = double.tryParse(paidText);
    if (newPaid != null && newPaid >= 0) {
      orderVM.updateOrderPaid(order.id!, newPaid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Consumer2<OrderViewModel, ItemViewModel>(
        builder: (context, orderVM, itemVM, child) {
          if (orderVM.isLoading || itemVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (orderVM.errorMessage != null) {
            return Center(child: Text(orderVM.errorMessage!));
          } else if (orderVM.paymentOrdersList.isEmpty) {
            return const Center(child: Text('No payment orders available.'));
          } else {
            return ListView.builder(
              itemCount: orderVM.paymentOrdersList.length,
              itemBuilder: (context, index) {
                final order = orderVM.paymentOrdersList[index];
                final customer = orderVM.customers.firstWhere(
                  (c) => c['id'] == order.customerId,
                  orElse: () => {'id': order.customerId, 'name': 'Unknown'},
                );
                final totalAmount = order.items.entries
                    .map((e) =>
                        itemVM.items
                            .firstWhere(
                              (i) => i.id == e.key,
                              orElse: () => Item(
                                  itemFor: '',
                                  length: 'N/A',
                                  name: e.key,
                                  price: 0.0,
                                  weight: 0),
                            )
                            .price *
                        e.value[0])
                    .reduce((a, b) => a + b);
                final isFullyPaid =
                    order.paid != null && order.paid! >= totalAmount;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  color: isFullyPaid ? Colors.green[100] : Colors.red[100],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order ID: ${order.id}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Customer: ${customer['name']}'),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Price')),
                              DataColumn(label: Text('Ordered')),
                              DataColumn(label: Text('Total')),
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
                                DataCell(Text(item.price.toStringAsFixed(2))),
                                DataCell(Text(e.value[0].toString())),
                                DataCell(Text(itemTotal.toStringAsFixed(2))),
                              ]);
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                'Total Amount: ${totalAmount.toStringAsFixed(2)}'),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: TextEditingController(
                                    text: order.paid?.toStringAsFixed(2) ?? ''),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Paid',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 0),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]')),
                                ],
                                onSubmitted: (value) =>
                                    _updatePaid(context, order, value),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              tooltip: 'Move to Delivery',
                              onPressed: () {
                                orderVM
                                    .moveOrderToDeliveryFromPayment(order.id!);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              tooltip: 'Move to History',
                              onPressed: () {
                                orderVM.moveOrderToHistory(order.id!);
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
