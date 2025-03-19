import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kumar_brooms/authmanagement/auth_manage.dart';
import 'package:kumar_brooms/home/owner_home.dart';
import 'package:kumar_brooms/home/manager_home.dart';
import 'package:kumar_brooms/home/employee_home.dart';
import 'package:kumar_brooms/home/worker_home.dart';
import 'package:kumar_brooms/screens/signin/signin.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  Future<bool> _checkAndUpdatePermission(String uid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      DocumentReference docRef =
          firestore.collection('permissions').doc('allowedUsers');
      DocumentSnapshot doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          'allowedUsers': {uid: false},
        });
        return false;
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Map<String, dynamic> allowedUsers = data['allowedUsers'] ?? {};

      if (allowedUsers.containsKey(uid)) {
        return allowedUsers[uid] == true;
      } else {
        await docRef.update({
          'allowedUsers.$uid': false,
        });
        return false;
      }
    } catch (e) {
      print('Error checking/updating permission: $e');
      return false;
    }
  }

  Future<String?> _fetchUserRole(String uid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.get('role') as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }

  Widget _getHomePageForRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'owner':
        return const OwnerHome();
      case 'manager':
        return const ManagerHome();
      case 'employee':
        return const EmployeeHome();
      case 'worker':
        return const WorkerHome();
      default:
        return const Center(
          child: Text(
            'Role not assigned. Contact Admin.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "An error occurred: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<bool>(
            future: _checkAndUpdatePermission(user.uid),
            builder: (context, permissionSnapshot) {
              if (permissionSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (permissionSnapshot.hasError) {
                return Center(
                  child: Text(
                    "Permission check error: ${permissionSnapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (permissionSnapshot.data == true) {
                return FutureBuilder<String?>(
                  future: _fetchUserRole(user.uid),
                  builder: (context, roleSnapshot) {
                    if (roleSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (roleSnapshot.hasError) {
                      return Center(
                        child: Text(
                          "Role fetch error: ${roleSnapshot.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    return _getHomePageForRole(roleSnapshot.data);
                  },
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AuthManage().getUserID(),
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const Text("Your Request Sent to Admin"),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        child: const Text("Sign Out"),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        } else {
          return const SigninScreen();
        }
      },
    );
  }
}
