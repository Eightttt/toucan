import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toucan/models/goalModel.dart';
import 'package:toucan/models/postModel.dart';
import 'package:toucan/models/userDataModel.dart';
import 'package:flutter_date_interval/flutter_date_interval.dart';

class DatabaseService {
  final String? uid;
  String? pathProfilePhoto;
  List<DateTime> notifDates = [];
  DatabaseService({required this.uid}) {
    pathProfilePhoto = "photos/users/${uid}_profilePhoto.jpg";
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
  Future<String?> uploadProfilePhoto(
      File? image, XFile? imageWeb, Function(UploadTask?) setUploadTask) async {
    final Reference ref;
    if (kIsWeb) {
      ref = FirebaseStorage.instance
          .refFromURL("gs://toucan-8676b.appspot.com/")
          .child(pathProfilePhoto!);
    } else {
      ref = FirebaseStorage.instance.ref().child(pathProfilePhoto!);
    }

    try {
      UploadTask uploadTask;
      if (kIsWeb) {
        if (imageWeb == null) return null;
        uploadTask = ref.putData(
            await imageWeb.readAsBytes(), SettableMetadata(contentType: 'jpg'));
      } else {
        if (image == null) return null;
        uploadTask = ref.putFile(File(image.path));
      }
      setUploadTask(uploadTask);
      final snapshot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      setUploadTask(null);
      return urlDownload;
    } catch (e) {
      print("Error uploading: $e");
      return null;
    }
  }

  // ===== GOALS =====
  // Future updateGoalData()
  Future updateGoalData(
    String? goalId,
    String title,
    String tag,
    DateTime startDate,
    DateTime endDate,
    int period,
    String frequency,
    String description,
    bool isPrivate,
  ) async {
    // Goal Id is null if creating a new Post
    if (uid != null) {
      await userDataCollection.doc(uid).collection("goals").doc(goalId).set({
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

  // Get goals list stream that are not yet done
  Stream<List<GoalModel>> get unarchivedGoals {
    return userDataCollection
        .doc(uid)
        .collection("goals")
        .where("endDate", isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .map(_goalsListFromSnapshot);
  }

  // goals list from snapshot
  List<GoalModel> _goalsListFromSnapshot(QuerySnapshot snapshot) {
    Set<DateTime> notifDatesSet = {};

    List<GoalModel> goalsList = snapshot.docs.map((doc) {
      GoalModel goal = GoalModel(
        doc.id,
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

      // Merge all notif dates to a set (remove duplicates)
      notifDatesSet.addAll(_getNotifDates(goal));
      return goal;
    }).toList();

    List<DateTime> sortedNotifDates = notifDatesSet.toList();
    sortedNotifDates.sort();
    notifDates = sortedNotifDates.take(7).toList();

    // Get the 7 soonest notif dates as a list
    print("==== SET OF DATES ====");
    notifDates.forEach((element) {
      print("Dates: $element");
    });
    return goalsList;
  }

  // Get first seven dates on when to notify user
  Iterable<DateTime> _getNotifDates(GoalModel goal) {
    // check start date
    // if in progress, start is today
    DateTime start = goal.startDate;
    if (goal.status == "in-progress") start = DateTime.now();

    Intervals interval = _getIntervalFromFrequency(goal.frequency);
    DateInterval dateInterval =
        DateInterval(startDate: start, interval: interval, period: goal.period);

    // check end date to limit size of dateInterval iterable
    // if end date is 6 months or more from now,
    // set end date to 6 months from today
    DateTime sixMonthsFromToday = DateTime.now().add(Duration(days: 30 * 6));
    DateTime end = goal.endDate;
    if (goal.endDate.isAfter(sixMonthsFromToday)) end = sixMonthsFromToday;
    return dateInterval.getDatesThrough(end).take(7);
  }

  // Get interval from frequency of Goal
  Intervals _getIntervalFromFrequency(String frequency) {
    if (frequency == "day/s") return Intervals.daily;
    if (frequency == "week/s") return Intervals.weekly;
    if (frequency == "month/s") return Intervals.monthly;
    return Intervals.yearly;
  }

  // Get individual goal stream
  Stream<GoalModel?> getGoal(String goalId) {
    return userDataCollection
        .doc(uid)
        .collection("goals")
        .doc(goalId)
        .snapshots()
        .map((goalSnapshot) =>
            !goalSnapshot.exists ? null : _goalFromSnapshot(goalSnapshot));
  }

  // goal from snapshot
  GoalModel _goalFromSnapshot(DocumentSnapshot goalSnapshot) {
    return GoalModel(
      goalSnapshot.id,
      goalSnapshot.get('title'),
      goalSnapshot.get('tag'),
      DateTime.fromMillisecondsSinceEpoch(
          (goalSnapshot.get('startDate') as Timestamp).millisecondsSinceEpoch),
      DateTime.fromMillisecondsSinceEpoch(
          (goalSnapshot.get('endDate') as Timestamp).millisecondsSinceEpoch),
      goalSnapshot.get('period'),
      goalSnapshot.get('frequency'),
      goalSnapshot.get('description'),
      goalSnapshot.get('isPrivate'),
    );
  }

  // delete goal in firebase
  Future deleteGoal(String goalId) async {
    DocumentReference goalRef =
        userDataCollection.doc(uid).collection("goals").doc(goalId);

    await deleteSubCollections(goalRef.collection('posts'));
    await goalRef.delete();
  }

  // ===== POSTS =====
  // Future updatePostData()
  Future<String?> updatePostData(
    String goalId,
    String? postId,
    String caption,
    String imageURL,
    bool isEdit,
  ) async {
    // Post Id is null if creating a new Post
    if (uid != null) {
      if (postId == null) {
        DocumentReference ref = await userDataCollection
            .doc(uid)
            .collection("goals")
            .doc(goalId)
            .collection("posts")
            .add({});
        return ref.id;
      }

      if (isEdit) {
        await userDataCollection
            .doc(uid)
            .collection("goals")
            .doc(goalId)
            .collection("posts")
            .doc(postId)
            .update({
          "caption": caption,
          "imageURL": imageURL,
          "isEdited": isEdit,
        });
      } else {
        await userDataCollection
            .doc(uid)
            .collection("goals")
            .doc(goalId)
            .collection("posts")
            .doc(postId)
            .update({
          "caption": caption,
          "imageURL": imageURL,
          "date": Timestamp.fromDate(DateTime.now()),
          "isEdited": isEdit,
        });
      }
    }
    return null;
  }

  // Upload Post Photo
  Future<String?> uploadPostPhoto(
    String goalId,
    String postId,
    File? image,
    XFile? imageWeb,
    Function(UploadTask?) setUploadTask,
  ) async {
    final Reference ref;
    String pathPostImage = 'photos/posts/$uid/$goalId/$postId.jpg';

    if (kIsWeb) {
      ref = FirebaseStorage.instance
          .refFromURL("gs://toucan-8676b.appspot.com/")
          .child(pathPostImage);
    } else {
      ref = FirebaseStorage.instance.ref().child(pathPostImage);
    }

    try {
      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = ref.putData(await imageWeb!.readAsBytes(),
            SettableMetadata(contentType: 'jpg'));
      } else {
        uploadTask = ref.putFile(File(image!.path));
      }
      setUploadTask(uploadTask);
      final snapshot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      setUploadTask(null);
      return urlDownload;
    } catch (e) {
      print("Error uploading: $e");
      return null;
    }
  }

  // posts list from snapshot
  List<PostModel> _postsListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return PostModel(
        doc.id,
        doc.get('caption'),
        doc.get('imageURL'),
        DateTime.fromMillisecondsSinceEpoch(
            (doc.get('date') as Timestamp).millisecondsSinceEpoch),
        doc.get('isEdited'),
      );
    }).toList();
  }

  // Get posts list stream
  Stream<List<PostModel>> getPosts(String goalId) {
    return userDataCollection
        .doc(uid)
        .collection("goals")
        .doc(goalId)
        .collection("posts")
        .snapshots()
        .map(_postsListFromSnapshot);
  }

  // Get individual post stream
  Stream<PostModel?> getPost(String goalId, String postId) {
    return userDataCollection
        .doc(uid)
        .collection("goals")
        .doc(goalId)
        .collection("posts")
        .doc(postId)
        .snapshots()
        .map((postSnapshot) =>
            !postSnapshot.exists ? null : _postFromSnapshot(postSnapshot));
  }

  // post from snapshot
  PostModel _postFromSnapshot(DocumentSnapshot postSnapshot) {
    return PostModel(
      postSnapshot.id,
      postSnapshot.get('caption'),
      postSnapshot.get('imageURL'),
      DateTime.fromMillisecondsSinceEpoch(
          (postSnapshot.get('date') as Timestamp).millisecondsSinceEpoch),
      postSnapshot.get('isEdited'),
    );
  }

  // delete post in firebase
  Future deletePost(String goalId, String postId) async {
    await userDataCollection
        .doc(uid)
        .collection("goals")
        .doc(goalId)
        .collection("posts")
        .doc(postId)
        .delete();
  }

  // delete subcollection
  Future deleteSubCollections(CollectionReference subcollectionRef) async {
    int batchSize = 500;
    QuerySnapshot snapshot = await subcollectionRef.limit(batchSize).get();

    while (snapshot.docs.isNotEmpty) {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      snapshot.docs.forEach((doc) => batch.delete(doc.reference));
      await batch.commit();
      snapshot = await subcollectionRef.limit(batchSize).get();
    }
  }

  // Add friends to friends list
}
