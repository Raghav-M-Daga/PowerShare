import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future deleteUser(String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser;

    user.delete();
  }
}
