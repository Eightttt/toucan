import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({required this.uid});

  // collection reference
  final CollectionReference userDataCollection =
      FirebaseFirestore.instance.collection('usersData');

  // Future updateUserData()

  Future updateUserData(String username, String description) async {
    // TODO: Add profile picture, friend code, friends list

    if (uid != null) {
      return await userDataCollection.doc(uid).set({
        "username": username,
        "description": description,
      });
    }
  }

  // Add friends to friends list
}
