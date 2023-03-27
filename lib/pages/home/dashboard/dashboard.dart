import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:provider/provider.dart';
import 'package:toucan/models/goalModel.dart';
import 'package:toucan/models/userDataModel.dart';
import 'package:toucan/pages/home/dashboard/createGoal.dart';
import "package:toucan/pages/home/dashboard/fadeappbar.dart";
import 'package:toucan/services/auth.dart';
import 'package:toucan/services/database.dart';
import '../../../shared/loading.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key, required this.uid}) : super(key: key);
  final String uid;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ScrollController _scrollController = ScrollController();
  bool lastStatus = true;
  double height = 220;
  bool _isAnimating = false;
  double _offset = 0;
  bool isLoading = true;
  bool isLoadingUserData = true;
  String description = "";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _scrollController.addListener(_setOffset);
    loadUserData(widget.uid);
  }

  Future loadUserData(String uid) async {
    UserDataModel userData = await DatabaseService(uid: uid).getUserData();
    toggleIsLoadingUserData();
    showLoading();
    setState(() {
      description = userData.getDescription;
    });
  }

  void showLoading() {
    setState(() {
      // TODO: Add loading boolean for goal
      if (!isLoadingUserData) {
        isLoading = false;
      } else {
        isLoading = true;
      }
    });
  }

  void toggleIsLoadingUserData() {
    isLoadingUserData = !isLoadingUserData;
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
          return CreateGoal(uid: widget.uid);
        });
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = new DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.position.isScrollingNotifier.addListener(() {
        if (_scrollController.position.isScrollingNotifier.value) {
          // print('scroll is started');
        } else if (!_isAnimating) {
          if (_isShrink &&
              _scrollController.offset < (height - kToolbarHeight + 10)) {
            _scrollDown();
          } else if (!_isShrink) {
            _scrollUp();
          }
        }
      });
    });

    return Stack(
      children: [
        Scaffold(
          body: AbsorbPointer(
            absorbing: _isAnimating,
            child: StreamProvider<List<GoalModel>>.value(
              value: DatabaseService(uid: widget.uid).goals,
              initialData: [],
              child: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      elevation: 5,
                      pinned: true,
                      expandedHeight: height,
                      title: FadingOnScroll(
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
                            FadingOnScroll(
                              scrollController: _scrollController,
                              offset: _offset,
                              child: IconButton(
                                disabledColor: Colors.black,
                                enableFeedback: !_isShrink ? false : true,
                                onPressed: _isShrink
                                    ? () => showDialog(
                                        context: context,
                                        builder: (context) => Settings())
                                    : null,
                                icon: Icon(Icons.settings),
                              ),
                            ),
                          ],
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        background: PageHeader(
                          today: today,
                          description: description,
                        ),
                      ),
                    ),
                  ];
                },
                body: GoalsListView(),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                showCreateGoalSheet();
              },
              child: Icon(
                Icons.add,
              )),
          bottomNavigationBar: BottomNavBar(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
        Visibility(
          visible: isLoading,
          child: Container(
            color: Color(0xFFFDFDF5),
            child: Loading(),
          ),
        ),
      ],
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    super.key,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(color: Color.fromARGB(69, 0, 0, 0), blurRadius: 10)
      ]),
      child: BottomNavigationBar(
        onTap: (index) => setState(() => currentIndex = index),
        currentIndex: currentIndex,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendar',
            backgroundColor: Color(0xFFFDFDF5),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            backgroundColor: Color(0xFFFDFDF5),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Socials',
            backgroundColor: Color(0xFFFDFDF5),
          ),
        ],
      ),
    );
  }
}

class GoalsListView extends StatefulWidget {
  const GoalsListView({
    super.key,
  });

  @override
  State<GoalsListView> createState() => _GoalsListViewState();
}

class _GoalsListViewState extends State<GoalsListView> {
  @override
  Widget build(BuildContext context) {
    final List<GoalModel> goals = Provider.of<List<GoalModel>>(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 36, 16, 70),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return goals.length == 0
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
                    : GoalCard(goal: goals[index]);
              },
              childCount: goals.length == 0 ? 1 : goals.length,
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
  });

  final GoalModel goal;
  final Color toucanWhite = Color(0xFFFDFDF5);
  final Color toucanRed = Color.fromARGB(255, 224, 88, 39);
  final Color toucanYellow = Color.fromARGB(255, 242, 203, 5);
  final Color toucanGreen = Color.fromRGBO(132, 195, 93, 1);

  Color statusColor(String status) {
    if (status == "not started") return toucanRed;
    if (status == "in-progress") return toucanYellow;
    return toucanGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 26),
      child: Stack(
        children: [
          ListTile(
            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            onTap: () {},
            title: Text(
              goal.title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                fontSize: 20,
              ),
            ),
            subtitle: Text(
              goal.tag,
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            visualDensity: VisualDensity(vertical: 4),
          ),
          IgnorePointer(
            ignoring: true,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              alignment: Alignment.bottomRight,
              width: double.infinity,
              height: 100,
              child: Container(
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
            ),
          ),
        ],
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  PageHeader({
    super.key,
    required this.today,
    required this.description,
  });

  final DateTime today;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Color(0xfff28705),
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    '${DateFormat('MMMM dd').format(today)}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      fontSize: 48,
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundImage: Image.asset(
                    "assets/temp-img1.png",
                    fit: BoxFit.cover,
                  ).image,
                  radius: MediaQuery.of(context).size.width * .125,
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
                IconButton(
                  color: Colors.black,
                  onPressed: () => showDialog(
                      context: context, builder: (context) => Settings()),
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

class Settings extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      iconPadding: EdgeInsets.only(top: 10, left: 5),
      icon: Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          color: Color(0xfff28705),
          iconSize: 30,
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.chevron_left),
        ),
      ),
      actionsPadding: EdgeInsets.only(bottom: 37),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 0, 45, 10),
          child: ElevatedButton(
            onPressed: () => {},
            child: Text(
              "Edit Profile",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 10, 45, 10),
          child: ElevatedButton(
            onPressed: () => {},
            child: Text(
              "Feedback",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(45, 10, 45, 10),
          child: ElevatedButton(
            onPressed: () => {},
            child: Text(
              "Archive",
              style: TextStyle(fontSize: 14),
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
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
    );
  }
}
