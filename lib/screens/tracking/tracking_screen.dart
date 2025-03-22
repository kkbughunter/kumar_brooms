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

  // List of tabs and corresponding screens
  final List<String> _tabs = [
    'Order',
    'Work',
    'Delivery',
    'Payment',
    'History',
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
        title: const Text('Tracking'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Allows scrolling if tabs exceed width
          tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _screens,
      ),
    );
  }
}
