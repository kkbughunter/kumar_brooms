import 'package:flutter/material.dart';
import 'package:kumar_brooms/authmanagement/auth_manage.dart';
import 'package:kumar_brooms/model/user.dart';
import 'package:kumar_brooms/repositorys/profile_repo.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  User? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileViewModel(this._profileRepository);

  User? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userProfile =
          await _profileRepository.getUserProfile(AuthManage().getUserID());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch profile: $e';
      notifyListeners();
    }
  }
}
