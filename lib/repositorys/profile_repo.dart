
import 'package:kumar_brooms/model/user.dart';

abstract class ProfileRepository {
  Future<User?> getUserProfile(String userId);
}