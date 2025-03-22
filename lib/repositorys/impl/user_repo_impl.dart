// lib/repositorys/impl/user_repo_impl.dart
import 'package:kumar_brooms/models/UserPermission.dart';
import 'package:kumar_brooms/repositorys/user_repo.dart';
import 'package:kumar_brooms/services/user_service.dart';

class UserRepositoryImpl implements UserRepository {
  final UserService _userService;

  UserRepositoryImpl(this._userService);

  @override
  Future<List<UserPermission>> getAllUsers() async {
    return await _userService.getAllUsers();
  }

  @override
  Future<void> updateUserPermission(String uid, bool isActive) async {
    await _userService.updateUserPermission(uid, isActive);
  }

  @override
  Future<void> updateUserDetails(String uid, UserPermission user) async {
    await _userService.updateUserDetails(uid, user);
  }

  @override
  Future<void> addUserDetails(String uid, UserPermission user) async {
    await _userService.addUserDetails(uid, user);
  }

  @override
  Future<void> deleteUserDetails(String uid) async {
    await _userService.deleteUserDetails(uid);
  }
}
