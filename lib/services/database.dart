import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:toucan/models/goalModel.dart';
import 'package:toucan/models/userDataModel.dart';

class DatabaseService {
  final String? uid;
  String? path;
  DatabaseService({required this.uid}) {
    path = "photos/users/${uid}_profilePhoto.jpg";
  }

  // collection reference
  final CollectionReference userDataCollection =
      FirebaseFirestore.instance.collection('usersData');

  // Future updateUserData()
  Future updateUserData(String username, String greeter,
      TimeOfDay notificationTime, String urlProfilePhoto) async {
    // TODO: Add profile picture, friend code, friends list

    if (uid != null) {
      await userDataCollection.doc(uid).set({
        "username": username,
        "greeter": greeter,
        "notificationTime": _timeOfDayToFirebase(notificationTime),
        "urlProfilePhoto": urlProfilePhoto,
      });
    }
  }

  // User data from snapshot
  UserDataModel _userDataFromSnapshot(DocumentSnapshot userDataDoc) {
    //
    return UserDataModel(
      userDataDoc.get("username"),
      userDataDoc.get("greeter"),
      _timeOfDayFromFirebase(userDataDoc.get("notificationTime")),
      userDataDoc.get("urlProfilePhoto"),
    );
  }

  // Get userdata stream
  Stream<UserDataModel> get userData {
    return userDataCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  // Format timeOfDay to Map to save in Firebase
  Map _timeOfDayToFirebase(TimeOfDay timeOfDay) {
    return {'hour': timeOfDay.hour, 'minute': timeOfDay.minute};
  }

  // Format Map from firebase to timeOfDay
  TimeOfDay _timeOfDayFromFirebase(Map data) {
    return TimeOfDay(hour: data['hour'], minute: data['minute']);
  }

  // Upload User's Profile Photo
  Future<String?> uploadProfilePhoto(File? image) async {
    final ref = FirebaseStorage.instance.ref().child(path!);
    if (image == null) return null;
    try {
      UploadTask uploadTask = ref.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      return urlDownload;
    } catch (e) {
      print("Error uploading: $e");
      return null;
    }
  }

  // ===== GOALS =====
  // Future updateGoalData()
  Future updateGoalData(
      String title,
      String tag,
      DateTime startDate,
      DateTime endDate,
      int period,
      String frequency,
      String description,
      bool isPrivate) async {
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
    return userDataCollection
        .doc(uid)
        .collection("goals")
        .snapshots()
        .map(_goalsListFromSnapshot);
  }

  // Add friends to friends list
}
