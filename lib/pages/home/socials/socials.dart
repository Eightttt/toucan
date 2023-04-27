import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toucan/models/postModel.dart';
import 'package:toucan/models/userDataModel.dart';
import 'package:toucan/pages/home/socials/followUser.dart';
import "package:intl/intl.dart";
import 'package:toucan/services/database.dart';
import 'package:toucan/shared/loading.dart';

class Socials extends StatefulWidget {
  final String uid;
  const Socials({super.key, required this.uid});

  @override
  State<Socials> createState() => _SocialsState();
}

class _SocialsState extends State<Socials> {
  Color toucanOrange = Color(0xfff28705);
  Color toucanWhite = Color(0xFFFDFDF5);
  List<PostModel>? yourFollowingsPosts;

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

  List<String> pictures = [
    "assets/1.jpg",
    "assets/2.jpg",
    "assets/3.jpg",
    "assets/4.jpg",
    "assets/5.jpg"
  ];

  @override
  Widget build(BuildContext context) {
    final UserDataModel? userData = Provider.of<UserDataModel?>(context);
    List<PostModel>? followingsPosts = Provider.of<List<PostModel>?>(context);

    if (followingsPosts != null && userData != null) {
      yourFollowingsPosts = followingsPosts
          .where((post) =>
              post.followCode != userData.followCode &&
              userData.followingList.contains(post.followCode))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 30,
        elevation: 4,
        title: Container(
          height: kToolbarHeight,
          color: toucanOrange,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            itemCount: pictures.length,
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.center,
                width: 80,
                child: GestureDetector(
                  onTap: () => print("clicked $index"),
                  child: ClipOval(
                    child: Image.asset(pictures[index]),
                  ),
                ),
              );
            },
          ),
        ),
        backgroundColor: toucanOrange,
      ),
      body: followingsPosts == null || userData == null
          ? Container(
              color: Color(0xFFFDFDF5),
              child: Loading(size: 40),
            )
          : ListView.builder(
              padding: EdgeInsets.only(top: 20, bottom: 80),
              itemCount: yourFollowingsPosts!.length,
              itemBuilder: (context, index) {
                return yourFollowingsPosts!.length == 0
                    ? Text(
                        "No posts to be found here\nFollow people to see their posts",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 2,
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.fromLTRB(32, 10, 32, 10),
                        child: PostCard(post: yourFollowingsPosts![index]),
                      );
              },
            ),
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
