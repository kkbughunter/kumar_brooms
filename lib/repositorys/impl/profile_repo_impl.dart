
import 'package:kumar_brooms/models/user.dart';
import 'package:kumar_brooms/repositorys/profile_repo.dart';
import 'package:kumar_brooms/services/profile_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;

  ProfileRepositoryImpl(this._profileService);

  @override
  Future<User?> getUserProfile(String userId) async {
    return await _profileService.getUserProfile(userId);
  }
}