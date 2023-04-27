import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toucan/models/postModel.dart';
import 'package:toucan/models/userDataModel.dart';
import 'package:toucan/pages/home/socials/followUser.dart';
import 'package:toucan/services/database.dart';

class TempSocials extends StatefulWidget {
  final String uid;
  const TempSocials({super.key, required this.uid});

  @override
  State<TempSocials> createState() => _TempSocialsState();
}

class _TempSocialsState extends State<TempSocials> {
  showFollowUser(int yourFollowCode, List<dynamic> yourFollowingList) {
    showDialog(
      context: context,
      builder: (context) => StreamProvider.value(
        value: DatabaseService(uid: widget.uid).existingUsers,
        initialData: null,
        catchError: (context, error) {
          print("Error: $error");
          return null; // return a default value
        },
        child: FollowUser(
          uid: widget.uid,
          followCode: yourFollowCode,
          followingList: yourFollowingList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserDataModel? userData = Provider.of<UserDataModel?>(context);
    List<PostModel>? followingsPosts = Provider.of<List<PostModel>?>(context);

    if (followingsPosts != null && userData != null) {
      List<PostModel> yourFollowingsPosts = followingsPosts
          .where((post) =>
              post.followCode != userData.followCode &&
              userData.followingList.contains(post.followCode))
          .toList();

      print("======== FOLLOW LIST ========");
      userData.followingList.forEach((element) {
        print(element);
      });
      print("======== FOLLOW CODE OF ALL POSTS ========");
      followingsPosts.forEach((element) {
        print(element.followCode);
      });
      print("\n\n==== POSTS THAT YOU ARE FOLLOWING ====");
      yourFollowingsPosts.forEach((post) {
        // TODO: filter based on followings list
        // TODO: from followings list, get UID

        print(post.caption);
        print(post.date);
        print(post.followCode);
        print(post.id);
        print(post.imageURL);
        print(post.isEdited);
        print("==== END ==== \n");
      });
    }

    return Scaffold(
      body: Container(),
      floatingActionButton: followingsPosts == null || userData == null
          ? null
          : FloatingActionButton(
              onPressed: () =>
                  showFollowUser(userData.followCode, userData.followingList),
              child: Icon(
                Icons.person_add_alt_1_rounded,
                size: 25,
              ),
            ),
    );
  }
}
