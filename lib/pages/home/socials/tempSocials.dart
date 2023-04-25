import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toucan/models/postModel.dart';
import 'package:toucan/pages/home/socials/followUser.dart';
import 'package:toucan/services/database.dart';

class TempSocials extends StatefulWidget {
  final String uid;
  const TempSocials({super.key, required this.uid});

  @override
  State<TempSocials> createState() => _TempSocialsState();
}

class _TempSocialsState extends State<TempSocials> {
  showFollowUser() async {
    int yourFollowCode = await DatabaseService(uid: widget.uid).followCode;
    List<dynamic> yourFollowingList =
        await DatabaseService(uid: widget.uid).followingList;

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
    List<PostModel>? followingsPosts = Provider.of<List<PostModel>?>(context);

    if (followingsPosts != null) {
      print(followingsPosts.map((e) {
        // TODO: filter based on followings list
        // TODO: from followings list, get UID
        print("\n\n==== POST ====");
        print(e.caption);
        print(e.date);
        print(e.id);
        print(e.imageURL);
        print(e.isEdited);
        print("==== END ==== \n");
      }));
    }

    return Scaffold(
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showFollowUser(),
        child: Icon(
          Icons.person_add_alt_1_rounded,
          size: 25,
        ),
      ),
    );
  }
}
