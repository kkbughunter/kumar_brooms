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
    return DateFormat('MMM dd, yyyy HH:mm').format(timestamp.toDate());
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Order Details - ${order.id}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Customer: ${customer['name']}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  const Text('Items:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
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
                          DataCell(Text('${item.weight}g')),
                          DataCell(Text('₹${item.price.toStringAsFixed(2)}')),
                          DataCell(Text(e.value[0].toString())),
                          DataCell(Text(e.value[1].toString())),
                          DataCell(Text('₹${itemTotal.toStringAsFixed(2)}')),
                        ]);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Timestamps:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
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
                  const SizedBox(height: 16),
                  const Text('Payment:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                  Text(
                      'Total Amount: ₹${order.items.entries.map((e) => itemVM.items.firstWhere((i) => i.id == e.key, orElse: () => Item(itemFor: '', length: 'N/A', name: e.key, price: 0.0, weight: 0)).price * e.value[0]).reduce((a, b) => a + b).toStringAsFixed(2)}'),
                  Text('Paid: ₹${order.paid?.toStringAsFixed(2) ?? 'N/A'}'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.teal)),
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.teal,
            colorScheme: const ColorScheme.light(primary: Colors.teal),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
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
      body: SafeArea(
        child: Column(
          children: [
            // Header with Search and Date Filter
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.teal.withOpacity(0.1),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Customer or Item Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Colors.teal),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.teal),
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDateRange == null
                              ? 'Filter by Date'
                              : 'Date: ${DateFormat('MMM dd, yy').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yy').format(_selectedDateRange!.end)}',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.teal),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.date_range,
                                color: Colors.teal),
                            onPressed: () => _selectDateRange(context),
                          ),
                          if (_selectedDateRange != null)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.teal),
                              onPressed: () {
                                setState(() {
                                  _selectedDateRange = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Orders List
            Expanded(
              child: Consumer2<OrderViewModel, ItemViewModel>(
                builder: (context, orderVM, itemVM, child) {
                  if (orderVM.isLoading || itemVM.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (orderVM.errorMessage != null) {
                    return Center(
                        child: Text(orderVM.errorMessage!,
                            style: const TextStyle(color: Colors.red)));
                  } else if (orderVM.historyOrdersList.isEmpty) {
                    return const Center(
                        child: Text('No history orders available.',
                            style:
                                TextStyle(fontSize: 16, color: Colors.grey)));
                  } else {
                    final filteredOrders =
                        orderVM.historyOrdersList.where((order) {
                      final customer = orderVM.customers.firstWhere(
                        (c) => c['id'] == order.customerId,
                        orElse: () =>
                            {'id': order.customerId, 'name': 'Unknown'},
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
                          child: Text('No matching orders found.',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)));
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

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () =>
                                _showOrderDetailsDialog(context, order),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Order ID: ${order.id}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal),
                                      ),
                                      const Icon(Icons.arrow_forward_ios,
                                          size: 16, color: Colors.teal),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Customer: ${customer['name']}',
                                      style: const TextStyle(fontSize: 14)),
                                  const SizedBox(height: 12),
                                  _buildTimestampRow('Order',
                                      timestamps['order_placed'], null),
                                  _buildTimestampRow(
                                      'Work',
                                      timestamps['work_started'],
                                      timestamps['order_placed']),
                                  _buildTimestampRow(
                                      'Delivery',
                                      timestamps['delivery_started'],
                                      timestamps['work_started']),
                                  _buildTimestampRow(
                                      'Payment',
                                      timestamps['payment_started'],
                                      timestamps['delivery_started']),
                                  _buildTimestampRow(
                                      'Completed',
                                      timestamps['history_started'],
                                      timestamps['payment_started']),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back,
                                            color: Colors.teal),
                                        tooltip: 'Move to Payment',
                                        onPressed: () {
                                          Provider.of<OrderViewModel>(context,
                                                  listen: false)
                                              .moveOrderToPaymentFromHistory(
                                                  order.id!);
                                        },
                                      ),
                                    ],
                                  ),
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
      ),
    );
  }

  Widget _buildTimestampRow(
      String label, Timestamp? timestamp, Timestamp? previous) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontSize: 14)),
          Text(
            '${_formatTimestamp(timestamp)} ${_calculateDaysDifference(previous, timestamp) != 'N/A' ? '(${_calculateDaysDifference(previous, timestamp)})' : ''}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
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
