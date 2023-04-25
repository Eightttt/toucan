import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toucan/models/goalModel.dart';
import 'package:toucan/models/postModel.dart';
import 'package:toucan/models/taskModel.dart';
import 'package:toucan/models/userDataModel.dart';
import 'dart:math';

class DatabaseService {
  final String? uid;
  String? pathProfilePhoto;
  DatabaseService({required this.uid}) {
    pathProfilePhoto = "photos/users/${uid}_profilePhoto.jpg";
  }

  // collection reference
  final CollectionReference userDataCollection =
      FirebaseFirestore.instance.collection('usersData');

  // Future initializeUserData()
  Future initializeUserData(String username, String greeter,
      TimeOfDay notificationTime, String urlProfilePhoto) async {
    if (uid != null) {
      await userDataCollection.doc(uid).set({
        "username": username,
        "followerCode": (DateTime.now().millisecondsSinceEpoch * 10000) +
            Random().nextInt(10000),
        "greeter": greeter,
        "notificationTime": _timeOfDayToFirebase(notificationTime),
        "urlProfilePhoto": urlProfilePhoto,
        "followingList": [],
      });
    }
  }

  // Future initializeUserData()
  Future updateUserData(
    String username,
    String greeter,
    TimeOfDay notificationTime,
    String urlProfilePhoto,
  ) async {
    if (uid != null) {
      await userDataCollection.doc(uid).set({
        "username": username,
        "greeter": greeter,
        "notificationTime": _timeOfDayToFirebase(notificationTime),
        "urlProfilePhoto": urlProfilePhoto,
      });
    }
  }

  // Add new Following to User Data
  Future addNewFollowing(
    String otherUid,
  ) async {
    if (uid != null) {
      DocumentSnapshot userDataDoc = await userDataCollection.doc(uid).get();
      List<String> followingList = await userDataDoc.get("followingList");
      followingList.add(otherUid);
      await userDataCollection.doc(uid).set({
        "followingList": followingList,
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

  // Goals list from snapshot
  List<GoalModel> _goalsListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map(
          (doc) => GoalModel(
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
          ),
        )
        .toList();
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

  // Goal from snapshot
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

  // Delete goal in firebase
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
          "uid": uid,
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

    // If platform is web
    if (kIsWeb) {
      ref = FirebaseStorage.instance
          .refFromURL("gs://toucan-8676b.appspot.com/")
          .child(pathPostImage);
    } else {
      ref = FirebaseStorage.instance.ref().child(pathPostImage);
    }

    try {
      UploadTask uploadTask;
      // If platform is web
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

  // Posts list from snapshot
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

  // Posts list from snapshot
  List<PostModel> _postsListOfOthersFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.where((doc) => doc.get("uid") != uid).map((doc) {
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

  // Get posts collection group stream
  Stream<List<PostModel>> get followingsPosts {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    // Shows posts today of all followings excluding user's own posts
    return FirebaseFirestore.instance
        .collectionGroup("posts")
        .where("date", isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .where("date", isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .snapshots()
        .map(_postsListOfOthersFromSnapshot);
  }

  // Post from snapshot
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

  // Delete post in firebase
  Future deletePost(String goalId, String postId) async {
    await userDataCollection
        .doc(uid)
        .collection("goals")
        .doc(goalId)
        .collection("posts")
        .doc(postId)
        .delete();
  }

  // ===== TASKS =====
  // Update Task Data
  Future updateTaskData(
    String? taskId,
    String title,
    DateTime date,
    bool isDone,
  ) async {
    // Task Id is null if creating a new Post
    if (uid != null) {
      await userDataCollection.doc(uid).collection("tasks").doc(taskId).set(
          {"title": title, "date": Timestamp.fromDate(date), "isDone": isDone});
    }
  }

  // Update task status if done or not
  Future updateTaskStatus(
    String taskId,
    bool isDone,
  ) async {
    if (uid != null) {
      await userDataCollection
          .doc(uid)
          .collection("tasks")
          .doc(taskId)
          .update({"isDone": isDone});
    }
  }

  // Get past Tasks list stream
  Stream<List<TaskModel>> get tasks {
    return userDataCollection
        .doc(uid)
        .collection("tasks")
        .snapshots()
        .map(_tasksListFromSnapshot);
  }

  // Tasks list from snapshot
  List<TaskModel> _tasksListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs
        .map(
          (doc) => TaskModel(
            doc.id,
            doc.get('title'),
            DateTime.fromMillisecondsSinceEpoch(
                (doc.get('date') as Timestamp).millisecondsSinceEpoch),
            doc.get('isDone'),
          ),
        )
        .toList();
  }

  // Delete Task in firebase
  Future deleteTask(String taskId) async {
    userDataCollection.doc(uid).collection("tasks").doc(taskId).delete();
  }

  // ==== Delete subcollection ====
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

  // TODO: Add friends list
}
