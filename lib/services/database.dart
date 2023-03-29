import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toucan/models/goalModel.dart';
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

  // User data from snapshot
  UserDataModel _userDataFromSnapshot(DocumentSnapshot userDataDoc) {
    //
    return UserDataModel(
        username: userDataDoc.get("username"),
        description: userDataDoc.get("description"));
  }

  // Get userdata stream
  Stream<UserDataModel> get userData {
    return userDataCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }


  // ===== GOALS =====
  // Future updateUserData()
  Future updateGoalData(
      String title,
      String tag,
      DateTime startDate,
      DateTime endDate,
      int period,
      String frequency,
      String description,
      bool isPrivate) async {
    // TODO: Add profile picture, friend code, friends list

    if (uid != null) {
      await userDataCollection.doc(uid).collection("goals").doc().set({
        "title": title,
        "tag": tag,
        "startDate": Timestamp.fromDate(startDate),
        "endDate": Timestamp.fromDate(endDate),
        "period": period,
        "frequency": frequency,
        "description": description,
        "isPrivate": isPrivate
      });
    }
  }

  // goals list from snapshot
  List<GoalModel> _goalsListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return GoalModel(
        doc.get('title'),
        doc.get('tag'),
        DateTime.fromMillisecondsSinceEpoch(
            (doc.get('startDate') as Timestamp).millisecondsSinceEpoch),
        DateTime.fromMillisecondsSinceEpoch(
            (doc.get('endDate') as Timestamp).millisecondsSinceEpoch),
        doc.get('period'),
        doc.get('frequency'),
        doc.get('description'),
        doc.get('isPrivate'),
      );
    }).toList();
  }

  // Get goals stream
  Stream<List<GoalModel>> get goals {
    return userDataCollection.doc(uid).collection("goals").snapshots().map(_goalsListFromSnapshot);
  }

  // Add friends to friends list
}
