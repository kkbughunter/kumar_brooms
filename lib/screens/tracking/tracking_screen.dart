import 'package:flutter/material.dart';
import 'package:kumar_brooms/screens/tracking/delivery/delivery_screen.dart';
import 'package:kumar_brooms/screens/tracking/history/history_screen.dart';
import 'package:kumar_brooms/screens/tracking/order/order_screen.dart';
import 'package:kumar_brooms/screens/tracking/payment/payment_screen.dart';
import 'package:kumar_brooms/screens/tracking/work/work_screen.dart';

class Tracking extends StatefulWidget {
  const Tracking({super.key});

  @override
  State<Tracking> createState() => _TrackingState();
}

class _TrackingState extends State<Tracking>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // List of tabs and corresponding screens with icons
  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Order', 'icon': Icons.shopping_cart},
    {'title': 'Work', 'icon': Icons.build},
    {'title': 'Delivery', 'icon': Icons.local_shipping},
    {'title': 'Payment', 'icon': Icons.payment},
    {'title': 'History', 'icon': Icons.history},
  ];
  final List<Widget> _screens = [
    const OrderScreen(),
    const WorkScreen(),
    const DeliveryScreen(),
    const PaymentScreen(),
    const HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tracking',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.blue[900],
          indicatorWeight: 3,
          labelColor: Colors.blue[900],
          unselectedLabelColor: Colors.blue,
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          tabs: _tabs
              .map((tab) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tab['icon'], size: 20),
                        const SizedBox(width: 8),
                        Text(tab['title']),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: _screens,
        ),
      ),
      
    );
  }
}
