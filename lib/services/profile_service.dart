
import 'package:kumar_brooms/model/user.dart';

abstract class ProfileService {
  Future<User?> getUserProfile(String userId);
}