import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:provider/provider.dart';
import 'package:toucan/models/goalModel.dart';
import 'package:toucan/models/postModel.dart';
import 'package:toucan/models/userDataModel.dart';
import 'package:toucan/pages/home/dashboard/editGoal.dart';
import 'package:toucan/pages/home/dashboard/editProfile.dart';
import 'package:toucan/pages/home/dashboard/viewGoal.dart';
import "package:toucan/shared/fadingOnScroll.dart";
import 'package:toucan/services/auth.dart';
import 'package:toucan/services/database.dart';
import 'package:toucan/services/notification.dart';
import '../../../shared/loading.dart';

class Dashboard extends StatefulWidget {
  final String? myUid;
  const Dashboard({Key? key, this.myUid}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ScrollController _scrollController = ScrollController();
  List<GoalModel>? prevUnarchivedGoals;
  UserDataModel? prevUserData;
  bool isScheduledNotifications = false;
  bool lastStatus = true;
  double height = 200;
  bool _isAnimating = false;
  double _offset = 0;
  int currentIndex = 1;

  Color toucanOrange = Color(0xfff28705);
  Color toucanWhite = Color(0xFFFDFDF5);

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

  _scrollDown() async {
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
  }

  _scrollUp() async {
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
  }

  bool get _isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (height - kToolbarHeight) / 2;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.removeListener(_setOffset);
    _scrollController.dispose();
    super.dispose();
  }

  showCreateGoalSheet() {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Color.fromARGB(85, 0, 0, 0),
        enableDrag: false,
        context: context,
        builder: (BuildContext context) {
          // Pass null to goalUid to create a new goal with a unique UID
          return EditGoal(goal: null);
        });
  }

  scheduleNotificationDates(List<GoalModel>? goals, UserDataModel? userData) {
    if (userData != null && goals != null) {
      List<GoalModel> unarchivedGoals = goals
          .where((goal) =>
              goal.endDate.isAfter(DateTime.now().subtract(Duration(days: 1))))
          .toList();
      if (userData != prevUserData || unarchivedGoals != prevUnarchivedGoals) {
        prevUserData = userData;
        prevUnarchivedGoals = unarchivedGoals;
        NotificationService().scheduleNotificationsFromGoal(
            goals: unarchivedGoals,
            notificationTime: userData.notificationTime,
            username: userData.username);
      }
    }
  }

  unfollowUser(String othersUid) async {
    await DatabaseService(uid: widget.myUid).unfollowUser(othersUid);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final UserDataModel? userData = Provider.of<UserDataModel?>(context);
    final List<GoalModel>? goals = Provider.of<List<GoalModel>?>(context);
    DateTime today = new DateTime.now();

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

      // Schedule the new notification dates as dashboard finished building
      if (widget.myUid == null) {
        scheduleNotificationDates(goals, userData);
      }
    });

    return Scaffold(
      body: goals == null || userData == null
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
                      titleSpacing: widget.myUid == null ? null : 0,
                      backgroundColor: Color(0xFFFDFDF5),
                      elevation: 5,
                      pinned: true,
                      expandedHeight: height,
                      leading: widget.myUid == null
                          ? null
                          : IconButton(
                              color: Colors.black,
                              icon: Icon(Icons.arrow_back_ios_new_sharp),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FadingOnScroll(
                            scrollController: _scrollController,
                            offset: _offset,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  "assets/toucan-title-logo.png",
                                  fit: BoxFit.fitHeight,
                                  height: kToolbarHeight,
                                ),
                                widget.myUid != null
                                    ? SizedBox()
                                    : IconButton(
                                        disabledColor: Colors.black,
                                        enableFeedback:
                                            !_isShrink ? false : true,
                                        onPressed: _isShrink
                                            ? () => showDialog(
                                                context: context,
                                                builder: (context) => Settings(
                                                      uid: userData.uid,
                                                    ))
                                            : null,
                                        icon: Icon(Icons.settings),
                                      ),
                              ],
                            ),
                          ),
                          widget.myUid == null
                              ? SizedBox()
                              : Padding(
                                  padding: const EdgeInsets.only(right: 36),
                                  child: ElevatedButton(
                                    onPressed: () => unfollowUser(userData.uid),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 2,
                                      side: BorderSide(
                                          width: 1, color: toucanWhite),
                                      minimumSize: Size(76, 33),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      "Unfollow",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      flexibleSpace: FlexibleAppBar(
                        today: today,
                        description: userData.greeter,
                        uid: userData.uid,
                        username: userData.username,
                        othersProfile: widget.myUid != null,
                        urlProfilePhoto: userData.urlProfilePhoto,
                      ),
                    ),
                  ];
                },
                body: GoalsListView(
                  uid: widget.myUid,
                  othersProfile: widget.myUid != null,
                  goals: goals,
                ),
              ),
            ),
      floatingActionButton: goals == null || widget.myUid != null
          ? null
          : FloatingActionButton(
              onPressed: () {
                showCreateGoalSheet();
              },
              child: Icon(
                Icons.add,
              )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ignore: must_be_immutable
class FlexibleAppBar extends StatelessWidget {
  FlexibleAppBar({
    super.key,
    required this.today,
    required this.description,
    required this.username,
    required this.uid,
    required this.othersProfile,
    required this.urlProfilePhoto,
  });

  final DateTime today;
  final String description;
  final String? uid;
  final bool othersProfile;
  final String username;
  final String urlProfilePhoto;
  final double imageSize = 100;
  bool hasInitialized = false;

  @override
  Widget build(BuildContext context) {
    final UserDataModel userData = Provider.of<UserDataModel>(context);
    return FlexibleSpaceBar(
      collapseMode: CollapseMode.parallax,
      background: Container(
        color: Color(0xfff28705),
        padding: EdgeInsets.only(
            top: AppBar().preferredSize.height / 2, left: 15, right: 15),
        child: othersProfile
            ? Padding(
                padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        color: Color(0xFFFDFDF5),
                        height: imageSize,
                        width: imageSize,
                        child: CachedNetworkImage(
                          imageUrl: urlProfilePhoto,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (context, url, progress) {
                            return Container(
                              margin: EdgeInsets.all(imageSize * .35),
                              width: imageSize * .3,
                              height: imageSize * .3,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CircularProgressIndicator(
                                color: Color(0xfff28705),
                                backgroundColor:
                                    Color.fromARGB(69, 242, 135, 5),
                                strokeWidth: 4,
                                value: progress.totalSize != null
                                    ? progress.downloaded / progress.totalSize!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                              maxLines: 4,
                              softWrap: true,
                            ),
                            SizedBox(height: 5),
                            Text(
                              description,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                              maxLines: 6,
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          !othersProfile
                              ? '${DateFormat('MMM dd').format(today)}'
                              : username,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 48,
                          ),
                        ),
                      ),
                      ClipOval(
                        child: Container(
                          color: Color(0xFFFDFDF5),
                          height: imageSize,
                          width: imageSize,
                          child: CachedNetworkImage(
                            imageUrl: urlProfilePhoto,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder: (context, url, progress) {
                              return Container(
                                margin: EdgeInsets.all(imageSize * .35),
                                width: imageSize * .3,
                                height: imageSize * .3,
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
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          description,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            fontSize: 20,
                          ),
                          maxLines: 4,
                          softWrap: true,
                        ),
                      ),
                      othersProfile
                          ? SizedBox()
                          : IconButton(
                              color: Colors.black,
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) =>
                                      Settings(uid: userData.uid)),
                              icon: Icon(Icons.settings),
                            ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class GoalsListView extends StatefulWidget {
  final List<GoalModel> goals;
  final String? uid;
  final bool othersProfile;

  GoalsListView({
    super.key,
    required this.goals,
    required this.uid,
    required this.othersProfile,
  });

  @override
  State<GoalsListView> createState() => _GoalsListViewState();
}

class _GoalsListViewState extends State<GoalsListView> {
  @override
  Widget build(BuildContext context) {
    final UserDataModel userData = Provider.of<UserDataModel>(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 36, 16, 70),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return widget.goals.length == 0
                    ? Text(
                        "No goals added yet\nClick the \"+\" button to add a goal",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 2,
                        ),
                      )
                    : GoalCard(
                        uid: userData.uid,
                        othersProfile: widget.uid != null,
                        goal: widget.goals[index]);
              },
              childCount: widget.goals.length == 0 ? 1 : widget.goals.length,
            ),
          ),
        ),
      ],
    );
  }
}

class GoalCard extends StatelessWidget {
  GoalCard({
    super.key,
    required this.goal,
    required this.uid,
    required this.othersProfile,
  });

  final GoalModel goal;
  final String uid;
  final bool othersProfile;
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
    final UserDataModel userData = Provider.of<UserDataModel>(context);
    return Card(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Stack(
        children: [
          ListTile(
            minVerticalPadding: 0,
            contentPadding: EdgeInsets.fromLTRB(20, 0, 0, 0),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MultiProvider(
                  providers: [
                    StreamProvider<GoalModel?>.value(
                      value: DatabaseService(uid: uid).getGoal(goal.id),
                      initialData: null,
                      catchError: (context, error) {
                        print("Error: $error");
                        return null; // return a default value
                      },
                    ),
                    StreamProvider<List<PostModel>?>.value(
                      value: DatabaseService(uid: uid).getPosts(goal.id),
                      initialData: null,
                      catchError: (context, error) {
                        print("Error: $error");
                        return null; // return a default value
                      },
                    ),
                  ],
                  child: ViewGoal(othersUid: userData.uid),
                ),
              ),
            ),
            title: SizedBox(
              height: 89,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  goal.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          IgnorePointer(
            ignoring: true,
            child: Container(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
              height: 89,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
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
            ),
          ),
          IgnorePointer(
            child: Container(
              height: 89,
              width: 9,
              decoration: BoxDecoration(
                color: tagColor(goal.tag),
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Settings extends StatelessWidget {
  final AuthService _authService = AuthService();
  final String uid;
  Settings({required this.uid});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      iconPadding: EdgeInsets.only(top: 10),
      icon: Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          color: Color(0xfff28705),
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      actionsPadding: EdgeInsets.only(bottom: 37),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 10),
          child: ElevatedButton(
            onPressed: () => {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StreamProvider<UserDataModel?>.value(
                    value: DatabaseService(uid: uid).userData,
                    initialData: null,
                    child: EditProfile(uid),
                  ),
                ),
              )
            },
            child: Text(
              "Edit Profile",
              style: TextStyle(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 4,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 10, 45, 10),
          child: ElevatedButton(
            onPressed: () {
              _authService.logout();
              Navigator.of(context).pop();
            },
            child: Text(
              "Log Out",
              style: TextStyle(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 4,
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
    );
  }
}
