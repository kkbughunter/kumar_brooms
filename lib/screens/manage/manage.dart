import 'package:flutter/material.dart';
import 'package:kumar_brooms/screens/manage/manage_customer/customer_screen.dart';
import 'package:kumar_brooms/screens/manage/manage_item/item_screen.dart';
import 'package:kumar_brooms/screens/manage/manage_users/user_manage_screen.dart';

class Manage extends StatefulWidget {
  const Manage({super.key});

  @override
  State<Manage> createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Manage",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildManageCard(
              context,
              icon: Icons.person,
              title: "Manage Users",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserManageScreen()),
              ),
            ),
            _buildManageCard(
              context,
              icon: Icons.group,
              title: "Manage Customers",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomerScreen()),
              ),
            ),
            _buildManageCard(
              context,
              icon: Icons.inventory,
              title: "Manage Items",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ItemScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageCard(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
