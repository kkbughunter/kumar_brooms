import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kumar_brooms/models/item.dart';
import 'package:kumar_brooms/models/order.dart';
import 'package:kumar_brooms/viewmodels/item_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/order_viewmodel.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderViewModel>(context, listen: false).fetchHistoryOrders();
      Provider.of<ItemViewModel>(context, listen: false).fetchAllItems();
    });
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
  }

  String _calculateDaysDifference(Timestamp? start, Timestamp? end) {
    if (start == null || end == null) return 'N/A';
    final difference = end.toDate().difference(start.toDate()).inDays;
    return '$difference days';
  }

  void _showOrderDetailsDialog(BuildContext context, Orders order) {
    final orderVM = Provider.of<OrderViewModel>(context, listen: false);
    final itemVM = Provider.of<ItemViewModel>(context, listen: false);
    final customer = orderVM.customers.firstWhere(
      (c) => c['id'] == order.customerId,
      orElse: () => {'id': order.customerId, 'name': 'Unknown'},
    );
    final timestamps = order.timestamps ?? {};

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order Details - ${order.id}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Customer: ${customer['name']}'),
                  const SizedBox(height: 8),
                  const Text('Items:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                          DataCell(Text(item.price.toStringAsFixed(2))),
                          DataCell(Text(e.value[0].toString())),
                          DataCell(Text(e.value[1].toString())),
                          DataCell(Text(itemTotal.toStringAsFixed(2))),
                        ]);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Timestamps:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      'Order Placed: ${_formatTimestamp(timestamps['order_placed'])}'),
                  Text(
                      'Work Started: ${_formatTimestamp(timestamps['work_started'])} (${_calculateDaysDifference(timestamps['order_placed'], timestamps['work_started'])})'),
                  Text(
                      'Delivery Started: ${_formatTimestamp(timestamps['delivery_started'])} (${_calculateDaysDifference(timestamps['work_started'], timestamps['delivery_started'])})'),
                  Text(
                      'Payment Started: ${_formatTimestamp(timestamps['payment_started'])} (${_calculateDaysDifference(timestamps['delivery_started'], timestamps['payment_started'])})'),
                  Text(
                      'Completed: ${_formatTimestamp(timestamps['history_started'])} (${_calculateDaysDifference(timestamps['payment_started'], timestamps['history_started'])})'),
                  const SizedBox(height: 8),
                  const Text('Payment:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      'Total Amount: ${order.items.entries.map((e) => itemVM.items.firstWhere((i) => i.id == e.key, orElse: () => Item(itemFor: '', length: 'N/A', name: e.key, price: 0.0, weight: 0)).price * e.value[0]).reduce((a, b) => a + b).toStringAsFixed(2)}'),
                  Text('Paid: ${order.paid?.toStringAsFixed(2) ?? 'N/A'}'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Customer or Item Name',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedDateRange == null
                        ? 'Filter by Date'
                        : 'Date: ${DateFormat('MM/dd/yy').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd/yy').format(_selectedDateRange!.end)}',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () => _selectDateRange(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    if (_selectedDateRange != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDateRange = null;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer2<OrderViewModel, ItemViewModel>(
              builder: (context, orderVM, itemVM, child) {
                if (orderVM.isLoading || itemVM.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (orderVM.errorMessage != null) {
                  return Center(child: Text(orderVM.errorMessage!));
                } else if (orderVM.historyOrdersList.isEmpty) {
                  return const Center(
                      child: Text('No history orders available.'));
                } else {
                  final filteredOrders =
                      orderVM.historyOrdersList.where((order) {
                    final customer = orderVM.customers.firstWhere(
                      (c) => c['id'] == order.customerId,
                      orElse: () => {'id': order.customerId, 'name': 'Unknown'},
                    );
                    final customerName =
                        customer['name'].toString().toLowerCase();
                    final itemNames = order.items.entries.map((e) {
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
                      return item.name.toLowerCase();
                    }).toList();

                    final orderPlaced = order.timestamps?['order_placed'];
                    final matchesSearch = _searchQuery.isEmpty ||
                        customerName.contains(_searchQuery) ||
                        itemNames.any((name) => name.contains(_searchQuery));
                    final matchesDate = _selectedDateRange == null ||
                        (orderPlaced != null &&
                            orderPlaced.toDate().isAfter(_selectedDateRange!
                                .start
                                .subtract(const Duration(days: 1))) &&
                            orderPlaced.toDate().isBefore(_selectedDateRange!
                                .end
                                .add(const Duration(days: 1))));

                    return matchesSearch && matchesDate;
                  }).toList();

                  if (filteredOrders.isEmpty) {
                    return const Center(
                        child: Text('No matching orders found.'));
                  }

                  return ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final customer = orderVM.customers.firstWhere(
                        (c) => c['id'] == order.customerId,
                        orElse: () =>
                            {'id': order.customerId, 'name': 'Unknown'},
                      );
                      final timestamps = order.timestamps ?? {};

                      return InkWell(
                        onTap: () => _showOrderDetailsDialog(context, order),
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Order ID: ${order.id}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text('Customer: ${customer['name']}'),
                                const SizedBox(height: 8),
                                Text(
                                    'Order Placed: ${_formatTimestamp(timestamps['order_placed'])}'),
                                Text(
                                    'Work Started: ${_formatTimestamp(timestamps['work_started'])} (${_calculateDaysDifference(timestamps['order_placed'], timestamps['work_started'])})'),
                                Text(
                                    'Delivery Started: ${_formatTimestamp(timestamps['delivery_started'])} (${_calculateDaysDifference(timestamps['work_started'], timestamps['delivery_started'])})'),
                                Text(
                                    'Payment Started: ${_formatTimestamp(timestamps['payment_started'])} (${_calculateDaysDifference(timestamps['delivery_started'], timestamps['payment_started'])})'),
                                Text(
                                    'Completed: ${_formatTimestamp(timestamps['history_started'])} (${_calculateDaysDifference(timestamps['payment_started'], timestamps['history_started'])})'),
                              ],
                            ),
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
