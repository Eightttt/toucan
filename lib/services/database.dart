import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toucan/models/userDataModel.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference userDataCollection =
      FirebaseFirestore.instance.collection('usersData');

  // Future updateUserData()

  Future updateUserData(String username, String description) async {
    // TODO: Add profile picture, friend code, friends list

    if (uid != null) {
      await userDataCollection.doc(uid).set({
        "username": username,
        "description": description,
      });
    }
  }

  // Get userdata stream
  Stream<QuerySnapshot> get userData {
    return userDataCollection.snapshots();
  }

  // Get user data
  Future<UserDataModel> getUserData() async {
    DocumentReference userDataDoc = userDataCollection.doc(uid);
    DocumentSnapshot userDataSnapshot = await userDataDoc.get();
    return _userDataFromSnapshot(userDataSnapshot);
  }

  // Get user data
  UserDataModel _userDataFromSnapshot(DocumentSnapshot userDataDoc) {
    //
    return UserDataModel(
        username: userDataDoc.get("username"),
        description: userDataDoc.get("description"));
  }

  // Add friends to friends list
}
