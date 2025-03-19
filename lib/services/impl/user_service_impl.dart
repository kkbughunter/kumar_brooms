// lib/services/impl/user_service_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kumar_brooms/model/UserPermission.dart';
import 'package:kumar_brooms/services/user_service.dart';

class UserServiceImpl implements UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<UserPermission>> getAllUsers() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> permSnapshot =
          await _firestore.collection('permissions').doc('allowedUsers').get();
      Map<String, dynamic>? allowedUsersData = permSnapshot.data();
      Map<String, dynamic> allowedUsers = allowedUsersData?['allowedUsers'] ?? {};
      print('Permissions data: $allowedUsers');

      List<UserPermission> users = [];
      for (var uid in allowedUsers.keys) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await _firestore.collection('users').doc(uid).get();
        print('User data for $uid: ${userSnapshot.data()}');
        users.add(UserPermission.fromJson(
          uid,
          allowedUsers[uid] == true,
          userSnapshot.data(),
        ));
      }
      print('Fetched ${users.length} users');
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  @override
  Future<void> updateUserPermission(String uid, bool isActive) async {
    try {
      await _firestore.collection('permissions').doc('allowedUsers').update({
        'allowedUsers.$uid': isActive,
      });
      print('Updated permission for $uid to $isActive');
    } catch (e) {
      print('Error updating permission: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserDetails(String uid, UserPermission user) async {
    try {
      await _firestore.collection('users').doc(uid).update(user.toJson());
      print('Updated user details for $uid');
    } catch (e) {
      print('Error updating user details: $e');
      rethrow;
    }
  }

  @override
  Future<void> addUserDetails(String uid, UserPermission user) async {
    try {
      await _firestore.collection('users').doc(uid).set(user.toJson());
      print('Added user details for $uid');
    } catch (e) {
      print('Error adding user details: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUserDetails(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      print('Deleted user details for $uid');
    } catch (e) {
      print('Error deleting user details: $e');
      rethrow;
    }
  }
}