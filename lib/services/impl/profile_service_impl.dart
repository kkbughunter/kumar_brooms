import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kumar_brooms/model/user.dart';
import '../profile_service.dart';

class ProfileServiceImpl implements ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<User?> getUserProfile(String userID) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestore.collection('users').doc(userID).get();

      if (documentSnapshot.exists) {
        return User.fromJson(documentSnapshot.data()!);
      } else {
        print('User profile not found for ID: $userID');
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
}
