import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kumar_brooms/authmanagement/auth_manage.dart';
import 'package:kumar_brooms/models/item.dart';
import 'package:kumar_brooms/models/order.dart';
import 'package:kumar_brooms/screens/manage/manage.dart';
import 'package:kumar_brooms/screens/profile/profile_screen.dart';
import 'package:kumar_brooms/screens/tracking/tracking_screen.dart';
import 'package:kumar_brooms/viewmodels/customer_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/order_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/item_viewmodel.dart';
import 'package:provider/provider.dart';

// OwnerHome widget remains unchanged
class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  String userID = "";
  int _currentIndex = 0;
  late List<Widget> body;

  @override
  void initState() {
    super.initState();
    userID = AuthManage().getUserID();
    body = [
      const Home(),
      const Tracking(),
      const Manage(),
      Profile(userId: userID),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Add SafeArea here
        child: Center(
          child: body[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.track_changes), label: "Track"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Manage"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_pin), label: "Profile"),
        ],
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderViewModel>(context, listen: false).fetchAllOrders();
      Provider.of<ItemViewModel>(context, listen: false).fetchAllItems();
      Provider.of<CustomerViewModel>(context, listen: false)
          .fetchAllCustomers();
    });
  }

  List<double> _calculateAverageDays(List<Orders> orders) {
    List<double> sums = [0, 0, 0, 0];
    List<int> counts = [0, 0, 0, 0];
    for (var order in orders) {
      final ts = order.timestamps ?? {};
      if (ts['order_placed'] != null && ts['work_started'] != null) {
        sums[0] += ts['work_started']!
            .toDate()
            .difference(ts['order_placed']!.toDate())
            .inDays
            .toDouble();
        counts[0]++;
      }
      if (ts['work_started'] != null && ts['delivery_started'] != null) {
        sums[1] += ts['delivery_started']!
            .toDate()
            .difference(ts['work_started']!.toDate())
            .inDays
            .toDouble();
        counts[1]++;
      }
      if (ts['delivery_started'] != null && ts['payment_started'] != null) {
        sums[2] += ts['payment_started']!
            .toDate()
            .difference(ts['delivery_started']!.toDate())
            .inDays
            .toDouble();
        counts[2]++;
      }
      if (ts['payment_started'] != null && ts['history_started'] != null) {
        sums[3] += ts['history_started']!
            .toDate()
            .difference(ts['payment_started']!.toDate())
            .inDays
            .toDouble();
        counts[3]++;
      }
    }
    return [
      counts[0] > 0 ? sums[0] / counts[0] : 0,
      counts[1] > 0 ? sums[1] / counts[1] : 0,
      counts[2] > 0 ? sums[2] / counts[2] : 0,
      counts[3] > 0 ? sums[3] / counts[3] : 0,
    ];
  }

  Map<String, int> _calculateItemWiseCount(
      List<Orders> historyOrders, ItemViewModel itemVM,
      {String? customerId}) {
    Map<String, int> itemCounts = {};
    for (var order in historyOrders) {
      if (customerId == null || order.customerId == customerId) {
        for (var itemEntry in order.items.entries) {
          final itemId = itemEntry.key;
          final orderedCount = itemEntry.value[0];
          final item = itemVM.items.firstWhere(
            (i) => i.id == itemId,
            orElse: () => Item(
                itemFor: '',
                length: 'N/A',
                name: itemId,
                price: 0.0,
                weight: 0),
          );
          itemCounts[item.name] = (itemCounts[item.name] ?? 0) + orderedCount;
        }
      }
    }
    return itemCounts;
  }

  double _calculateTotalEarned(
      List<Orders> historyOrders, ItemViewModel itemVM) {
    double totalEarned = 0;
    for (var order in historyOrders) {
      for (var itemEntry in order.items.entries) {
        final itemId = itemEntry.key;
        final orderedCount = itemEntry.value[0];
        final item = itemVM.items.firstWhere(
          (i) => i.id == itemId,
          orElse: () => Item(
              itemFor: '', length: 'N/A', name: itemId, price: 0.0, weight: 0),
        );
        totalEarned += item.price * orderedCount;
      }
    }
    return totalEarned;
  }

  double _calculateTotalWeightSold(
      List<Orders> historyOrders, ItemViewModel itemVM) {
    double totalWeight = 0;
    for (var order in historyOrders) {
      for (var itemEntry in order.items.entries) {
        final itemId = itemEntry.key;
        final orderedCount = itemEntry.value[0];
        final item = itemVM.items.firstWhere(
          (i) => i.id == itemId,
          orElse: () => Item(
              itemFor: '', length: 'N/A', name: itemId, price: 0.0, weight: 0),
        );
        totalWeight +=
            item.weight * orderedCount; // Assuming weight is in grams
      }
    }
    return totalWeight / 1000; // Convert grams to kilograms
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<OrderViewModel, ItemViewModel, CustomerViewModel>(
      builder: (context, orderVM, itemVM, customerVM, child) {
        if (orderVM.isLoading || itemVM.isLoading || customerVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (orderVM.errorMessage != null ||
            itemVM.errorMessage != null ||
            customerVM.errorMessage != null) {
          return Center(
              child: Text(orderVM.errorMessage ??
                  itemVM.errorMessage ??
                  customerVM.errorMessage!));
        }

        final ordersByStage = [
          orderVM.trackingOrders.length,
          orderVM.workOrders.length,
          orderVM.deliveryOrders.length,
          orderVM.paymentOrders.length,
          orderVM.historyOrders.length,
        ];

        final customerItemCounts = _calculateItemWiseCount(
            orderVM.historyOrdersList, itemVM,
            customerId: _selectedCustomerId);
        final customerItemNames = customerItemCounts.keys.toList();
        final customerItemValues =
            customerItemCounts.values.map((count) => count.toDouble()).toList();

        final totalEarned =
            _calculateTotalEarned(orderVM.historyOrdersList, itemVM);
        final totalWeight =
            _calculateTotalWeightSold(orderVM.historyOrdersList, itemVM);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Orders by Stage Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Orders by Stage',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [
                                BarChartRodData(
                                    toY: ordersByStage[0].toDouble(),
                                    color: Colors.blue,
                                    width: 20)
                              ]),
                              BarChartGroupData(x: 1, barRods: [
                                BarChartRodData(
                                    toY: ordersByStage[1].toDouble(),
                                    color: Colors.green,
                                    width: 20)
                              ]),
                              BarChartGroupData(x: 2, barRods: [
                                BarChartRodData(
                                    toY: ordersByStage[2].toDouble(),
                                    color: Colors.orange,
                                    width: 20)
                              ]),
                              BarChartGroupData(x: 3, barRods: [
                                BarChartRodData(
                                    toY: ordersByStage[3].toDouble(),
                                    color: Colors.purple,
                                    width: 20)
                              ]),
                              BarChartGroupData(x: 4, barRods: [
                                BarChartRodData(
                                    toY: ordersByStage[4].toDouble(),
                                    color: Colors.red,
                                    width: 20)
                              ]),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 60,
                                  getTitlesWidget: (value, meta) {
                                    const titles = [
                                      'Order',
                                      'Work',
                                      'Delivery',
                                      'Payment',
                                      'History'
                                    ];
                                    return Transform.rotate(
                                      angle: -45 * 3.14159 / 180,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(titles[value.toInt()],
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Customer Item Purchases Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Item Purchases',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            final allNames = customerVM.customers
                                .map((customer) => customer.name);
                            if (textEditingValue.text.isEmpty) {
                              return allNames;
                            }
                            return allNames.where((name) => name
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          fieldViewBuilder: (context, controller, focusNode,
                              onFieldSubmitted) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Search Customer',
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _selectedCustomerId = null;
                                      controller.clear();
                                    });
                                  },
                                ),
                              ),
                              onSubmitted: (value) => onFieldSubmitted(),
                            );
                          },
                          onSelected: (String customerName) {
                            final selectedCustomer = customerVM.customers
                                .firstWhere((customer) =>
                                    customer.name == customerName);
                            setState(() {
                              _selectedCustomerId = selectedCustomer.id;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: customerItemCounts.isEmpty
                            ? const Center(
                                child: Text(
                                  'No items purchased by this customer',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SizedBox(
                                  width: customerItemNames.length * 80.0,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      barGroups: List.generate(
                                        customerItemNames.length,
                                        (index) => BarChartGroupData(
                                          x: index,
                                          barRods: [
                                            BarChartRodData(
                                              toY: customerItemValues[index],
                                              color: Colors.blue,
                                              width: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                      titlesData: FlTitlesData(
                                        leftTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        rightTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false)),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 60,
                                            getTitlesWidget: (value, meta) {
                                              final index = value.toInt();
                                              if (index >= 0 &&
                                                  index <
                                                      customerItemNames
                                                          .length) {
                                                return Transform.rotate(
                                                  angle: -45 * 3.14159 / 180,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Text(
                                                      customerItemNames[index],
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const Text('');
                                            },
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      gridData: const FlGridData(show: false),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Total Earnings and Weight Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Company Earnings & Weight Sold',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [
                                BarChartRodData(
                                    toY: totalEarned,
                                    color: Colors.green,
                                    width: 30)
                              ]),
                              BarChartGroupData(x: 1, barRods: [
                                BarChartRodData(
                                    toY: totalWeight,
                                    color: Colors.blue,
                                    width: 30)
                              ]),
                            ],
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const titles = [
                                      'Earnings (₹)',
                                      'Weight (kg)'
                                    ];
                                    return Text(titles[value.toInt()],
                                        style: const TextStyle(fontSize: 14));
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Earned: ₹${totalEarned.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.green),
                          ),
                          Text(
                            'Weight Sold: ${totalWeight.toStringAsFixed(2)} kg',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
