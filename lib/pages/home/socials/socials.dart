import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toucan/models/goalModel.dart';
import 'package:toucan/models/postModel.dart';
import 'package:toucan/models/userDataModel.dart';
import 'package:toucan/models/userModel.dart';
import 'package:toucan/pages/home/dashboard/dashboard.dart';
import 'package:toucan/pages/home/socials/followUser.dart';
import "package:intl/intl.dart";
import 'package:toucan/services/database.dart';
import 'package:toucan/shared/loading.dart';

class Socials extends StatefulWidget {
  const Socials({super.key});

  @override
  State<Socials> createState() => _SocialsState();
}

class _SocialsState extends State<Socials> {
  Color toucanOrange = Color(0xfff28705);
  Color toucanWhite = Color(0xFFFDFDF5);
  List<PostModel>? yourFollowingsPosts;
  List<UserDataModel>? yourFollowingsUserData;
  final double imageSize = 60;

  showFollowUser(
      String uid, int yourFollowCode, List<dynamic> yourFollowingList) {
    showDialog(
      context: context,
      builder: (context) => StreamProvider.value(
        value: DatabaseService(uid: uid).existingUsers,
        initialData: null,
        catchError: (context, error) {
          print("Error: $error");
          return null; // return a default value
        },
        child: FollowUser(
          uid: uid,
          followCode: yourFollowCode,
          followingList: yourFollowingList,
        ),
      ),
    );
  }

  openFollowingUserProfile(String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MultiProvider(
            providers: [
              StreamProvider<UserDataModel?>.value(
                value: DatabaseService(uid: uid).userData,
                initialData: null,
              ),
              StreamProvider<List<GoalModel>?>.value(
                value: DatabaseService(uid: uid).goals,
                initialData: null,
                catchError: (context, error) {
                  print("Error: $error");
                  return null; // return a default value
                },
              ),
            ],
            child: Dashboard(othersUid: uid),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserModel user = Provider.of<UserModel>(context);
    final UserDataModel? userData = Provider.of<UserDataModel?>(context);
    final List<PostModel>? followingsPosts =
        Provider.of<List<PostModel>?>(context);
    final List<UserDataModel>? followingsUserData =
        Provider.of<List<UserDataModel>?>(context);

    if (followingsPosts != null &&
        userData != null &&
        followingsUserData != null) {
      yourFollowingsPosts = followingsPosts
          .where((post) =>
              post.followCode != userData.followCode &&
              userData.followingList.contains(post.followCode))
          .toList();

      yourFollowingsUserData = followingsUserData
          .where((followingUserData) =>
              followingUserData.followCode != userData.followCode &&
              userData.followingList.contains(followingUserData.followCode))
          .toList();
    }

    return Scaffold(
      appBar: followingsPosts == null ||
              userData == null ||
              followingsUserData == null
          ? null
          : AppBar(
              toolbarHeight: kToolbarHeight + 30,
              elevation: 4,
              title: Container(
                height: imageSize,
                color: toucanOrange,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: yourFollowingsUserData!.length == 0
                      ? 1
                      : yourFollowingsUserData!.length,
                  itemBuilder: (context, index) {
                    return yourFollowingsUserData!.length == 0
                        ? ClipOval(
                            child: Image.asset("assets/toucan-title-logo.png"),
                          )
                        : Padding(
                            padding: EdgeInsets.only(left: 8, right: 8),
                            child: ClipOval(
                              child: Container(
                                width: imageSize,
                                height: imageSize,
                                color: toucanWhite,
                                child: GestureDetector(
                                  onTap: () => openFollowingUserProfile(
                                      yourFollowingsUserData![index].uid),
                                  child: CachedNetworkImage(
                                    imageUrl: yourFollowingsUserData![index]
                                        .urlProfilePhoto,
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder:
                                        (context, url, progress) {
                                      return Container(
                                        margin: EdgeInsets.all(imageSize * .2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: CircularProgressIndicator(
                                          color: Color(0xfff28705),
                                          backgroundColor:
                                              Color.fromARGB(69, 242, 135, 5),
                                          strokeWidth: 4,
                                          value: progress.totalSize != null
                                              ? progress.downloaded /
                                                  progress.totalSize!
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                  },
                ),
              ),
              backgroundColor: toucanOrange,
            ),
      body: followingsPosts == null ||
              userData == null ||
              followingsUserData == null
          ? Container(
              color: Color(0xFFFDFDF5),
              child: Loading(size: 40),
            )
          : ListView.builder(
              padding: EdgeInsets.only(top: 20, bottom: 80),
              itemCount: yourFollowingsPosts!.length == 0
                  ? 1
                  : yourFollowingsPosts!.length,
              itemBuilder: (context, index) {
                return yourFollowingsPosts!.length == 0
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(32, 50, 32, 10),
                        child: Text(
                          "No posts to be found here\nFollow people to see their posts",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            height: 2,
                          ),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.fromLTRB(32, 10, 32, 10),
                        child: PostCard(post: yourFollowingsPosts![index]),
                      );
              },
            ),
      floatingActionButton: followingsPosts == null ||
              userData == null ||
              followingsUserData == null
          ? null
          : FloatingActionButton(
              onPressed: () => showFollowUser(
                  user.uid, userData.followCode, userData.followingList),
              child: Icon(
                Icons.person_add_alt_1_rounded,
                size: 25,
              ),
            ),
    );
  }
}

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
  });

  final PostModel post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final toucanWhite = Color(0xFFFDFDF5);
  final toucanOrange = Color(0xfff28705);
  String caption = "";
  bool isExpand = false;

  @override
  Widget build(BuildContext context) {
    caption = widget.post.caption;
    bool canExpand = caption.length >= 100 || caption.contains('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "${widget.post.username} ",
                    style: TextStyle(
                      color: toucanOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '- ${DateFormat('MMM d, yy h:mm a').format(widget.post.date)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Color.fromARGB(255, 91, 91, 91)),
                  ),
                  Text(
                    widget.post.isEdited ? ' - edited' : '',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        color: Color.fromARGB(255, 91, 91, 91)),
                  ),
                ],
              ),
            ),
          ],
        ),
        Card(
          child: SizedBox(
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: widget.post.imageURL,
                errorWidget: (context, url, error) => Icon(Icons.error),
                progressIndicatorBuilder: (context, url, progress) {
                  return SizedBox(
                    height: progress.progress != null ? 300 : 100,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xfff28705),
                        backgroundColor: Color.fromARGB(69, 242, 135, 5),
                        strokeWidth: 4,
                        value: progress.totalSize != null
                            ? progress.downloaded / progress.totalSize!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 3, 5, 10),
          child: canExpand
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpand = !isExpand;
                    });
                  },
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: isExpand
                              ? caption
                              : caption.contains('\n') &&
                                      caption.indexOf('\n') < 100
                                  ? caption.substring(0, caption.indexOf('\n'))
                                  : caption.substring(0, 100),
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        TextSpan(
                          text: isExpand ? ' ... show less' : ' ... show more',
                          style: TextStyle(
                            color: Color.fromARGB(183, 91, 91, 91),
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    maxLines: isExpand ? null : 4,
                    softWrap: true,
                  ),
                )
              : Text(
                  caption,
                  style: TextStyle(
                    fontSize: 15,
                  ),
                  maxLines: 4,
                  softWrap: true,
                ),
        )
      ],
    );
  }
}
