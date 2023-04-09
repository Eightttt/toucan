import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toucan/models/goalModel.dart';
import 'package:toucan/models/postModel.dart';
import 'package:toucan/models/userDataModel.dart';
import 'package:toucan/models/userModel.dart';
import 'package:toucan/pages/home/dashboard/editPost.dart';
import 'package:toucan/services/database.dart';
import 'package:toucan/shared/fadingOnScroll.dart';
import 'package:toucan/shared/loading.dart';
import "package:intl/intl.dart";
import 'editGoal.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ViewGoal extends StatefulWidget {
  const ViewGoal({super.key});

  @override
  State<ViewGoal> createState() => _ViewGoalState();
}

class _ViewGoalState extends State<ViewGoal> {
  final ScrollController _scrollController = ScrollController();
  bool lastStatus = true;
  double height = 200;
  bool _isAnimating = false;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _scrollController.addListener(_setOffset);
  }

  void _scrollListener() {
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  void _setOffset() {
    setState(() {
      _offset = _scrollController.offset;
    });
  }

  // TODO: check link: https://stackoverflow.com/questions/56071731/scrollcontroller-how-can-i-detect-scroll-start-stop-and-scrolling
  _scrollDown() async {
    // print("start animation down");
    setState(() {
      _isAnimating = true;
    });
    await _scrollController
        .animateTo(
      height - kToolbarHeight + 10,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    )
        .then((_) {
      setState(() {
        _isAnimating = false;
      });
    });
    // print("end animation down");
  }

  _scrollUp() async {
    // print("start animation up");
    setState(() {
      _isAnimating = true;
    });
    await _scrollController
        .animateTo(
      _scrollController.position.minScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    )
        .then((_) {
      setState(() {
        _isAnimating = false;
      });
    });

    // print("end animation up");
  }

  bool get _isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (height - kToolbarHeight) / 2;
  }

  showEditGoalSheet(String uid, GoalModel goal) {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Color.fromARGB(85, 0, 0, 0),
        enableDrag: false,
        context: context,
        builder: (BuildContext context) {
          return EditGoal(
            uid: uid,
            goal: goal,
          );
        });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.removeListener(_setOffset);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<PostModel>? posts = Provider.of<List<PostModel>?>(context);
    final GoalModel? goal = Provider.of<GoalModel?>(context);
    final UserModel user = Provider.of<UserModel>(context);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.position.isScrollingNotifier.addListener(() {
        if (!_scrollController.position.isScrollingNotifier.value &&
            !_isAnimating) {
          if (_isShrink &&
              _scrollController.offset < (height - kToolbarHeight + 10)) {
            _scrollDown();
          } else if (!_isShrink) {
            _scrollUp();
          }
        }
      });
    });

    return Scaffold(
      body: posts == null || goal == null
          ? Stack(
              children: [
                ListView(
                  controller: _scrollController,
                  children: [],
                ),
                Container(
                  color: Color(0xFFFDFDF5),
                  child: Loading(size: 40),
                ),
              ],
            )
          : AbsorbPointer(
              absorbing: _isAnimating,
              child: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      leading: IconButton(
                        color: Colors.black,
                        icon: Icon(Icons.arrow_back_ios_new_sharp),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      backgroundColor: Color(0xFFFDFDF5),
                      elevation: 5,
                      pinned: true,
                      expandedHeight: height,
                      titleSpacing: 0,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FadingOnScroll(
                            scrollController: _scrollController,
                            offset: _offset,
                            child: Image.asset(
                              "assets/toucan-title-logo.png",
                              fit: BoxFit.fitHeight,
                              height: kToolbarHeight,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: IconButton(
                                color: Colors.black,
                                icon: Icon(Icons.more_horiz),
                                onPressed: () =>
                                    showEditGoalSheet(user.uid, goal)),
                          ),
                        ],
                      ),
                      flexibleSpace: FlexibleAppBar(
                        goal: goal,
                      ),
                    ),
                  ];
                },
                body: PostsListView(
                  posts: posts,
                  uid: user.uid,
                  goalId: goal.id,
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StreamProvider<UserDataModel?>.value(
                value: DatabaseService(uid: user.uid).userData,
                initialData: null,
                child: EditPost(
                  uid: user.uid,
                  goalId: goal?.id,
                  post: null,
                ),
              ),
            ),
          );
        },
        child: Icon(
          Icons.add,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }
}

// ignore: must_be_immutable
class FlexibleAppBar extends StatelessWidget {
  FlexibleAppBar({
    super.key,
    required this.goal,
  });

  final GoalModel goal;
  final double imageSize = 100;
  bool hasInitialized = false;

  final Color toucanWhite = Color(0xFFFDFDF5);
  final Color toucanRed = Color.fromARGB(255, 224, 88, 39);
  final Color toucanYellow = Color.fromARGB(255, 242, 203, 5);
  final Color toucanGreen = Color.fromARGB(255, 132, 195, 93);
  final Color toucanBlue = Color.fromARGB(255, 127, 192, 251);
  final Color toucanPurple = Color.fromARGB(255, 167, 127, 251);
  final Color toucanPeach = Color.fromARGB(255, 251, 179, 127);

  Color statusColor(String status) {
    if (status == "not started") return toucanRed;
    if (status == "in-progress") return toucanYellow;
    return toucanGreen;
  }

  Color tagColor(String status) {
    if (status == "Academic") return toucanBlue;
    if (status == "Work") return toucanPurple;
    return toucanPeach;
  }

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      collapseMode: CollapseMode.parallax,
      background: Container(
        color: Color(0xfff28705),
        padding: EdgeInsets.only(
            top: AppBar().preferredSize.height / 2, left: 45, right: 36),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Text(
                    goal.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                    ),
                  ),
                ),
                Text(
                  goal.description,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                  maxLines: 4,
                  softWrap: true,
                ),
                SizedBox(height: 10),
              ],
            ),
            ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 10, bottom: 20),
                    padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                    child: Text(
                      goal.tag,
                      style: TextStyle(
                        color: toucanWhite,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: tagColor(goal.tag),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                        //more than 50% of width makes circle
                        ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                    child: Text(
                      goal.status,
                      style: TextStyle(
                        color: toucanWhite,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: statusColor(goal.status),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                        //more than 50% of width makes circle
                        ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PostsListView extends StatefulWidget {
  final List<PostModel> posts;
  final String uid;
  final String goalId;

  PostsListView({
    super.key,
    required this.posts,
    required this.uid,
    required this.goalId,
  });

  @override
  State<PostsListView> createState() => _PostsListViewState();
}

class _PostsListViewState extends State<PostsListView> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(32, 6, 32, 90),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return widget.posts.length == 0
                    ? Text(
                        "No posts added yet\nClick the \"+\" button to add a post",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 2,
                        ),
                      )
                    : PostCard(
                        post: widget.posts[index],
                        uid: widget.uid,
                        goalId: widget.goalId,
                      );
              },
              childCount: widget.posts.length == 0 ? 1 : widget.posts.length,
            ),
          ),
        ),
      ],
    );
  }
}

class PostCard extends StatefulWidget {
  PostCard({
    super.key,
    required this.post,
    required this.uid,
    required this.goalId,
  });

  final PostModel post;
  final String uid;
  final String goalId;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final Color toucanWhite = Color(0xFFFDFDF5);

  String caption = "";
  bool isExpand = false;

  showEditPost() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StreamProvider<UserDataModel?>.value(
          value: DatabaseService(uid: widget.uid).userData,
          initialData: null,
          child: EditPost(
            uid: widget.uid,
            goalId: widget.goalId,
            post: widget.post,
          ),
        ),
      ),
    );
  }

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
              child: Text(
                '${DateFormat('MMMM dd').format(widget.post.date)}',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    color: Color.fromARGB(255, 91, 91, 91)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0, bottom: 3),
              child: IconButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.bottomRight,
                  color: Color.fromARGB(255, 91, 91, 91),
                  icon: Icon(Icons.more_horiz),
                  onPressed: () => showEditPost()),
            )
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
                            fontStyle: FontStyle.italic,
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
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 4,
                  softWrap: true,
                ),
        )
      ],
    );
  }
}
