import "package:firebase_auth/firebase_auth.dart";
import "package:toucan/pages/models/userModel.dart";

class AuthService {
  final FirebaseAuth _authService = FirebaseAuth.instance;

  // register with email and password
  Future register(String email, String password) async {
    try {
      UserCredential result = await _authService.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebase(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // authService change user stream
  Stream<UserModel?> get user {
    return _authService.authStateChanges().map(_userFromFirebase);
  }

  // sign in with email and password
  Future login(String email, String password) async {
    try {
      UserCredential result = await _authService.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebase(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future logout() async {
    try {
      return await _authService.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  UserModel? _userFromFirebase(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }
}
