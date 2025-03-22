// lib/services/user_service.dart
import 'package:kumar_brooms/models/UserPermission.dart';

abstract class UserService {
  Future<List<UserPermission>> getAllUsers();
  Future<void> updateUserPermission(String uid, bool isActive);
  Future<void> updateUserDetails(String uid, UserPermission user);
  Future<void> addUserDetails(String uid, UserPermission user);
  Future<void> deleteUserDetails(String uid);
}