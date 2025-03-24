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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Update Payment', style: TextStyle(color: Colors.teal)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16)),
            Text('Current Paid: ₹${currentPaid.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16)),
            if (advanceAmount > 0)
              Text('Advance Available: ₹${advanceAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, color: Colors.green)),
            const SizedBox(height: 12),
            TextField(
              controller: currentPaidController,
              decoration: InputDecoration(
                labelText: 'Enter Paid Amount',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon:
                    const Icon(Icons.currency_rupee, color: Colors.teal),
              ),
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
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    double currentPaidInput =
        double.tryParse(currentPaidController.text) ?? 0.0;
    if (currentPaidInput < 0) return;

    double totalPaid = currentPaid + currentPaidInput;
    double newAdvance = advanceAmount;
    double newPending = customer.pendingAmount;

    if (totalPaid > totalAmount) {
      double excessAmount = totalPaid - totalAmount;
      newAdvance += excessAmount; // Add excess to advance
      totalPaid = totalAmount; // Cap paid at total amount
    }

    if (advanceAmount > 0 && totalPaid < totalAmount) {
      bool? applyAdvance = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Apply Advance?',
              style: TextStyle(color: Colors.teal)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Advance: ₹${advanceAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16)),
              Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16)),
              Text('Current Paid: ₹${totalPaid.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes', style: TextStyle(color: Colors.teal)),
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
          newAdvance -= advanceToUse;
        }
      }
    }

    // Update customer only if advance changes
    if (newAdvance != customer.advanceAmount) {
      final updatedCustomer = Customer(
        id: customer.id,
        name: customer.name,
        phone1: customer.phone1,
        phone2: customer.phone2,
        shopAddress: customer.shopAddress,
        shopName: customer.shopName,
        advanceAmount: newAdvance,
        pendingAmount: newPending,
        advanceLastUpdate: Timestamp.now(),
        pendingLastUpdate: customer.pendingLastUpdate,
      );
      await customerVM.updateCustomer(customer.id!, updatedCustomer);
    }

    orderVM.updateOrderPaid(order.id!, totalPaid);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Update Payment', style: TextStyle(color: Colors.teal)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16)),
            Text('Current Paid: ₹${currentPaid.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16)),
            if (advanceAmount > 0)
              Text('Advance: ₹${advanceAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, color: Colors.green)),
            if (pendingAmount > 0)
              Text('Pending: ₹${pendingAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, color: Colors.red)),
            const SizedBox(height: 12),
            TextField(
              controller: currentPaidController,
              decoration: InputDecoration(
                labelText: 'Enter Paid Amount',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon:
                    const Icon(Icons.currency_rupee, color: Colors.teal),
              ),
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
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    double currentPaidInput =
        double.tryParse(currentPaidController.text) ?? 0.0;
    if (currentPaidInput < 0) return;

    double totalPaid = currentPaid + currentPaidInput;
    double newAdvance = advanceAmount;
    double newPending = pendingAmount;

    if (totalPaid > totalAmount) {
      double excessAmount = totalPaid - totalAmount;
      newAdvance += excessAmount; // Add excess to advance
      totalPaid = totalAmount; // Cap paid at total amount
    }

    if (advanceAmount > 0 && totalPaid < totalAmount) {
      bool? applyAdvance = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Apply Advance?',
              style: TextStyle(color: Colors.teal)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Advance: ₹${advanceAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16)),
              Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16)),
              Text('Current Paid: ₹${totalPaid.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes', style: TextStyle(color: Colors.teal)),
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
          newAdvance -= advanceToUse;
        }
      }
    }

    // Update pending if underpaid
    if (totalPaid < totalAmount) {
      newPending = totalAmount - totalPaid;
    } else if (totalPaid == totalAmount) {
      newPending = 0; // Clear pending if fully paid
    }

    // Update customer if advance or pending changes
    if (newAdvance != customer.advanceAmount ||
        newPending != customer.pendingAmount) {
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
    }

    await orderVM.updateOrderPaid(order.id!, totalPaid);
    orderVM.moveOrderToHistory(order.id!);
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
            } else if (orderVM.paymentOrdersList.isEmpty) {
              return const Center(
                  child: Text('No payment orders available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey)));
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: orderVM.paymentOrdersList.length,
                itemBuilder: (context, index) {
                  final order = orderVM.paymentOrdersList[index];
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
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: isFullyPaid ? Colors.green[50] : Colors.red[50],
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order ID: ${order.id}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal),
                              ),
                              Icon(
                                isFullyPaid
                                    ? Icons.check_circle
                                    : Icons.warning,
                                color: isFullyPaid ? Colors.green : Colors.red,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${customer.name}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
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
                                    label: Text('Price',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Qty',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                DataColumn(
                                    label: Text('Total',
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
                                final itemTotal = item.price * e.value[0];
                                return DataRow(cells: [
                                  DataCell(Text(item.name)),
                                  DataCell(Text(
                                      '₹${item.price.toStringAsFixed(2)}')),
                                  DataCell(Text(e.value[0].toString())),
                                  DataCell(
                                      Text('₹${itemTotal.toStringAsFixed(2)}')),
                                ]);
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: ₹${totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton(
                                onPressed: () => _updatePaid(context, order),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                child: Text(
                                  order.paid != null
                                      ? 'Paid: ₹${order.paid!.toStringAsFixed(2)}'
                                      : 'Add Payment',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.teal),
                                tooltip: 'Move to Delivery',
                                onPressed: () {
                                  orderVM.moveOrderToDeliveryFromPayment(
                                      order.id!);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward,
                                    color: Colors.teal),
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
      ),
    );
  }
}
