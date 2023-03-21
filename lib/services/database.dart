import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  final String username;
  DatabaseService({required this.uid, required this.username});

  // collection reference
  final CollectionReference userDataCollection =
      FirebaseFirestore.instance.collection('userDatas');

      // Future updateUserData()
}
