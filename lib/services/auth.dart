import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import 'package:toucan/models/userModel.dart';
import 'package:toucan/services/database.dart';

class AuthService {
  final FirebaseAuth _authService = FirebaseAuth.instance;

  // register with email and password
  Future register(String email, String password, String username) async {
    try {
      UserCredential result = await _authService.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // create new document for user
      await DatabaseService(uid: user?.uid).initializeUserData(
        username,
        "Have a great day, Toucan!",
        TimeOfDay(hour: 8, minute: 0),
        "https://firebasestorage.googleapis.com/v0/b/toucan-8676b.appspot.com/o/photos%2Fusers%2Fdefault_profilePhoto.jpg?alt=media&token=277b1cf0-af1c-44d6-b1da-8838d4f7b189",
      );

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
