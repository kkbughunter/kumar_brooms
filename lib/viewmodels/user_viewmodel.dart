// lib/viewmodels/user_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:kumar_brooms/authmanagement/auth_manage.dart';
import 'package:kumar_brooms/models/UserPermission.dart';
import 'package:kumar_brooms/repositorys/user_repo.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  List<UserPermission> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserRole;

  UserViewModel(this._userRepository) {
    fetchAllUsers();
    _setCurrentUserRole();
  }

  List<UserPermission> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get role => _currentUserRole;

  void _setCurrentUserRole() {
    String uid = AuthManage().getUserID();
    _currentUserRole = _users
        .firstWhere(
          (user) => user.uid == uid,
          orElse: () => UserPermission(
            uid: uid,
            isActive: false,
            name: '', // Assuming UserPermission has these fields directly
            phone: '',
            role: 'worker', // Default role
          ),
        )
        .role; // Access role directly from UserPermission
    notifyListeners();
  }

  Future<void> fetchAllUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _users = await _userRepository.getAllUsers();
      print('Users in viewmodel: ${_users.map((u) => u.uid)}');
      _setCurrentUserRole();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch users: $e';
      print('ViewModel error: $e');
      notifyListeners();
    }
  }

  Future<void> updateUserPermission(String uid, bool isActive) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.updateUserPermission(uid, isActive);
      await fetchAllUsers();
      print('Permission updated and users refreshed');
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update permission: $e';
      print('Error in updateUserPermission: $e');
      notifyListeners();
    }
  }

  Future<void> updateUserDetails(String uid, UserPermission user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userRepository.updateUserDetails(uid, user);
      await fetchAllUsers();
    } catch (e) {
      _errorMessage = 'Failed to update user details: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUserDetails(String uid, UserPermission user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userRepository.addUserDetails(uid, user);
      await fetchAllUsers();
    } catch (e) {
      _errorMessage = 'Failed to add user details: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUserDetails(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userRepository.deleteUserDetails(uid);
      await fetchAllUsers();
    } catch (e) {
      _errorMessage = 'Failed to delete user details: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
