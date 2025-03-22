
import 'package:kumar_brooms/models/user.dart';

abstract class ProfileService {
  Future<User?> getUserProfile(String userId);
}