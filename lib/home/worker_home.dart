import 'package:flutter/material.dart';
import 'package:kumar_brooms/authmanagement/auth_manage.dart';
import 'package:kumar_brooms/screens/profile/profile_screen.dart';
import 'package:kumar_brooms/screens/tracking/order/order_screen.dart';
import 'package:kumar_brooms/screens/tracking/work/work_screen.dart'; // Import OrderScreen

class WorkerHome extends StatefulWidget {
  const WorkerHome({super.key});

  @override
  State<WorkerHome> createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome> {
  String userID = "";
  int _currentIndex = 0;
  late List<Widget> body;

  @override
  void initState() {
    super.initState();
    userID = AuthManage().getUserID();
    body = [
      const WorkScreen(), // Replace with OrderScreen
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
          BottomNavigationBarItem(
              icon: Icon(Icons.track_changes), label: "Track"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_pin), label: "Profile"),
        ],
      ),
    );
  }
}
