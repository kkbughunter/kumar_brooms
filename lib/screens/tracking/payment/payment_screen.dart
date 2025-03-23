import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kumar_brooms/models/customer.dart';
import 'package:kumar_brooms/models/item.dart';
import 'package:kumar_brooms/models/order.dart';
import 'package:kumar_brooms/viewmodels/customer_viewmodel.dart';
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
      Provider.of<CustomerViewModel>(context, listen: false)
          .fetchAllCustomers();
    });
  }

  Future<void> _updatePaid(BuildContext context, Orders order) async {
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
    final customerVM = Provider.of<CustomerViewModel>(context, listen: false);
    final itemVM = Provider.of<ItemViewModel>(context, listen: false);

    double totalAmount = order.items.entries
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
    double currentPaid = order.paid ?? 0.0;
    final customer = customerVM.customers.firstWhere(
      (c) => c.id == order.customerId,
      orElse: () => Customer(
        name: 'Unknown',
        phone1: '',
        phone2: '',
        shopAddress: '',
        shopName: '',
      ),
    );
    double advanceAmount = customer.advanceAmount;

    TextEditingController currentPaidController = TextEditingController();
    bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total order amount: \$${totalAmount.toStringAsFixed(2)}'),
            Text('Current paid: \$${currentPaid.toStringAsFixed(2)}'),
            if (advanceAmount > 0)
              Text(
                  'Customer has \$${advanceAmount.toStringAsFixed(2)} advance.'),
            TextField(
              controller: currentPaidController,
              decoration:
                  const InputDecoration(labelText: 'Enter Current Paid Amount'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (proceed == true) {
      double currentPaidInput =
          double.tryParse(currentPaidController.text) ?? 0.0;
      if (currentPaidInput < 0) return;

      double totalPaid = currentPaid + currentPaidInput;

      if (advanceAmount > 0) {
        bool? applyAdvance = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Apply Advance Amount?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Customer has \$${advanceAmount.toStringAsFixed(2)} advance.'),
                Text('Total order amount: \$${totalAmount.toStringAsFixed(2)}'),
                Text(
                    'Current paid (including input): \$${totalPaid.toStringAsFixed(2)}'),
              ],
            ),
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

        if (applyAdvance == true) {
          double remainingAmount = totalAmount - totalPaid;
          double advanceToUse =
              advanceAmount > remainingAmount ? remainingAmount : advanceAmount;

          if (advanceToUse > 0) {
            totalPaid += advanceToUse;
            double newAdvance = advanceAmount - advanceToUse;
            double newPending = remainingAmount > advanceToUse
                ? remainingAmount - advanceToUse
                : 0;

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
              pendingLastUpdate:
                  newPending > 0 ? Timestamp.now() : customer.pendingLastUpdate,
            );
            await customerVM.updateCustomer(customer.id!, updatedCustomer);
          }
        }
      }

      // Update order paid
      orderVM.updateOrderPaid(order.id!, totalPaid);
    }
  }

  Future<void> _moveToHistory(BuildContext context, Orders order) async {
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
    final customerVM = Provider.of<CustomerViewModel>(context, listen: false);
    final itemVM = Provider.of<ItemViewModel>(context, listen: false);

    double totalAmount = order.items.entries
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
    double currentPaid = order.paid ?? 0.0;
    final customer = customerVM.customers.firstWhere(
      (c) => c.id == order.customerId,
      orElse: () => Customer(
        name: 'Unknown',
        phone1: '',
        phone2: '',
        shopAddress: '',
        shopName: '',
      ),
    );
    double advanceAmount = customer.advanceAmount;
    double pendingAmount = customer.pendingAmount;

    TextEditingController currentPaidController = TextEditingController();
    bool? proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Payment Before Moving'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total order amount: \$${totalAmount.toStringAsFixed(2)}'),
            Text('Current paid: \$${currentPaid.toStringAsFixed(2)}'),
            if (advanceAmount > 0)
              Text('Customer advance: \$${advanceAmount.toStringAsFixed(2)}'),
            if (pendingAmount > 0)
              Text('Customer pending: \$${pendingAmount.toStringAsFixed(2)}'),
            TextField(
              controller: currentPaidController,
              decoration:
                  const InputDecoration(labelText: 'Enter Current Paid Amount'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    double currentPaidInput =
        double.tryParse(currentPaidController.text) ?? 0.0;
    if (currentPaidInput < 0) return;

    double totalPaid = currentPaid + currentPaidInput;

    // Apply advance if available
    if (advanceAmount > 0) {
      bool? applyAdvance = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Apply Advance Amount?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Customer has \$${advanceAmount.toStringAsFixed(2)} advance.'),
              Text('Total order amount: \$${totalAmount.toStringAsFixed(2)}'),
              Text(
                  'Current paid (including input): \$${totalPaid.toStringAsFixed(2)}'),
            ],
          ),
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

      if (applyAdvance == true) {
        double remainingAmount = totalAmount - totalPaid;
        double advanceToUse =
            advanceAmount > remainingAmount ? remainingAmount : advanceAmount;

        if (advanceToUse > 0) {
          totalPaid += advanceToUse;
          advanceAmount -= advanceToUse;
        }
      }
    }

    // Check for overpayment
    double newAdvance = advanceAmount;
    double newPending = pendingAmount;
    if (totalPaid > totalAmount) {
      double excessAmount = totalPaid - totalAmount;
      bool? addToAdvance = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Handle Excess Payment'),
          content: Text(
            'Total paid (\$${totalPaid.toStringAsFixed(2)}) exceeds order amount (\$${totalAmount.toStringAsFixed(2)}). '
            'Add excess (\$${excessAmount.toStringAsFixed(2)}) to customer advance?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No (Keep as is)'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (addToAdvance == true) {
        newAdvance += excessAmount;
        totalPaid = totalAmount; // Cap paid at total amount
      } else {
        // Excess remains in paid, no adjustment to advance or pending
      }
    } else if (totalPaid < totalAmount) {
      newPending = totalAmount - totalPaid; // Update pending if underpaid
    } else {
      newPending = 0; // Fully paid, clear pending
    }

    // Update customer
    final updatedCustomer = Customer(
      id: customer.id,
      name: customer.name,
      phone1: customer.phone1,
      phone2: customer.phone2,
      shopAddress: customer.shopAddress,
      shopName: customer.shopName,
      advanceAmount: newAdvance,
      pendingAmount: newPending,
      advanceLastUpdate: newAdvance != customer.advanceAmount
          ? Timestamp.now()
          : customer.advanceLastUpdate,
      pendingLastUpdate: newPending != customer.pendingAmount
          ? Timestamp.now()
          : customer.pendingLastUpdate,
    );
    await customerVM.updateCustomer(customer.id!, updatedCustomer);

    // Update order paid
    await orderVM.updateOrderPaid(order.id!, totalPaid);

    // Move to history
    orderVM.moveOrderToHistory(order.id!);
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
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 0),
                                  backgroundColor: Colors.grey[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    side: const BorderSide(color: Colors.grey),
                                  ),
                                ),
                                onPressed: () => _updatePaid(context, order),
                                child: Text(
                                  order.paid != null
                                      ? '\$${order.paid!.toStringAsFixed(2)}'
                                      : 'Enter Paid',
                                  style: const TextStyle(color: Colors.black),
                                ),
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
                              onPressed: () => _moveToHistory(context, order),
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
