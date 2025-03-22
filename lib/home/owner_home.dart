// lib/screens/owner_home.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kumar_brooms/authmanagement/auth_manage.dart';
import 'package:kumar_brooms/models/item.dart';
import 'package:kumar_brooms/models/order.dart';
import 'package:kumar_brooms/screens/manage/manage.dart';
import 'package:kumar_brooms/screens/profile/profile_screen.dart';
import 'package:kumar_brooms/screens/tracking/tracking_screen.dart';
import 'package:kumar_brooms/viewmodels/order_viewmodel.dart';
import 'package:kumar_brooms/viewmodels/item_viewmodel.dart';
import 'package:provider/provider.dart';

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
      body: Center(
        child: body[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        type: BottomNavigationBarType.fixed,
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderViewModel>(context, listen: false).fetchAllOrders();
      Provider.of<ItemViewModel>(context, listen: false).fetchAllItems();
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
      List<Orders> historyOrders, ItemViewModel itemVM) {
    Map<String, int> itemCounts = {};
    for (var order in historyOrders) {
      for (var itemEntry in order.items.entries) {
        final itemId = itemEntry.key;
        final orderedCount = itemEntry.value[0];
        final item = itemVM.items.firstWhere(
          (i) => i.id == itemId,
          orElse: () => Item(
              itemFor: '', length: 'N/A', name: itemId, price: 0.0, weight: 0),
        );
        itemCounts[item.name] = (itemCounts[item.name] ?? 0) + orderedCount;
      }
    }
    return itemCounts;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<OrderViewModel, ItemViewModel>(
      builder: (context, orderVM, itemVM, child) {
        if (orderVM.isLoading || itemVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (orderVM.errorMessage != null ||
            itemVM.errorMessage != null) {
          return Center(
              child: Text(orderVM.errorMessage ?? itemVM.errorMessage!));
        }

        // Data for Orders by Stage Bar Chart
        final ordersByStage = [
          orderVM.trackingOrders.length,
          orderVM.workOrders.length,
          orderVM.deliveryOrders.length,
          orderVM.paymentOrders.length,
          orderVM.historyOrders.length,
        ];

        // Data for Completed vs Incomplete Pie Chart
        int totalOrdered = 0;
        int totalCompleted = 0;
        for (var order in orderVM.historyOrdersList) {
          for (var item in order.items.entries) {
            totalOrdered += item.value[0];
            totalCompleted += item.value[1];
          }
        }
        final totalIncomplete = totalOrdered - totalCompleted;

        // Data for Average Days Bar Chart
        final avgDays = _calculateAverageDays(orderVM.historyOrdersList);

        // Data for Item-wise Count Bar Chart
        final itemCounts =
            _calculateItemWiseCount(orderVM.historyOrdersList, itemVM);
        final itemNames = itemCounts.keys.toList();
        final itemValues =
            itemCounts.values.map((count) => count.toDouble()).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Orders by Stage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                            color: Colors.blue)
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(
                            toY: ordersByStage[1].toDouble(),
                            color: Colors.green)
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(
                            toY: ordersByStage[2].toDouble(),
                            color: Colors.orange)
                      ]),
                      BarChartGroupData(x: 3, barRods: [
                        BarChartRodData(
                            toY: ordersByStage[3].toDouble(),
                            color: Colors.purple)
                      ]),
                      BarChartGroupData(x: 4, barRods: [
                        BarChartRodData(
                            toY: ordersByStage[4].toDouble(), color: Colors.red)
                      ]),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 40)),
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
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(titles[value.toInt()],
                                    style: const TextStyle(fontSize: 12)),
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
              const SizedBox(height: 32),
              const Text('Completed vs Incomplete Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: totalCompleted.toDouble(),
                        color: Colors.green,
                        title: 'Completed\n$totalCompleted',
                        radius: 50,
                        titleStyle:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: totalIncomplete.toDouble(),
                        color: Colors.red,
                        title: 'Incomplete\n$totalIncomplete',
                        radius: 50,
                        titleStyle:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Average Days per Stage Transition',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(toY: avgDays[0], color: Colors.blue)
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(toY: avgDays[1], color: Colors.green)
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(toY: avgDays[2], color: Colors.orange)
                      ]),
                      BarChartGroupData(x: 3, barRods: [
                        BarChartRodData(toY: avgDays[3], color: Colors.purple)
                      ]),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: true, reservedSize: 40)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            const titles = [
                              'Order->Work',
                              'Work->Delivery',
                              'Delivery->Payment',
                              'Payment->History'
                            ];
                            return Transform.rotate(
                              angle: -45 * 3.14159 / 180,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(titles[value.toInt()],
                                    style: const TextStyle(fontSize: 12)),
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
              const SizedBox(height: 32),
              const Text('Item-wise Count in History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 300, // Increased height for potentially more items
                child: itemCounts.isEmpty
                    ? const Center(child: Text('No items in history'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: itemNames.length *
                              60.0, // Dynamic width based on item count
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barGroups: List.generate(
                                itemNames.length,
                                (index) => BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: itemValues[index],
                                      color: Colors
                                          .teal, // Consistent color; can vary if desired
                                    ),
                                  ],
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(
                                        showTitles: true, reservedSize: 40)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 60,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 &&
                                          index < itemNames.length) {
                                        return Transform.rotate(
                                          angle: -45 * 3.14159 / 180,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              itemNames[index],
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
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
        );
      },
    );
  }
}
