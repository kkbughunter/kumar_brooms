// lib/repositorys/user_repo.dart
import 'package:kumar_brooms/model/UserPermission.dart';

abstract class UserRepository {
  Future<List<UserPermission>> getAllUsers();
  Future<void> updateUserPermission(String uid, bool isActive);
  Future<void> updateUserDetails(String uid, UserPermission user);
  Future<void> addUserDetails(String uid, UserPermission user);
  Future<void> deleteUserDetails(String uid);
}