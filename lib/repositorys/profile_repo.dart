
import 'package:kumar_brooms/models/user.dart';

abstract class ProfileRepository {
  Future<User?> getUserProfile(String userId);
}