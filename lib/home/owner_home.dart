import 'package:flutter/material.dart';
import 'package:kumar_brooms/screens/manage/manage.dart';
import 'package:kumar_brooms/screens/manage/manage_item/item_screen.dart';
import 'package:kumar_brooms/screens/manage/manage_users/user_manage_screen.dart';
import 'package:kumar_brooms/screens/profile/profile_screen.dart';
import '/authmanagement/auth_manage.dart';

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
      Text("hello1"),
      Text("hello2"),
      Manage(),
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
