import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:toucan/pages/home/dashboard/creategoal.dart';
import "package:toucan/pages/home/dashboard/fadeappbar.dart";
import 'package:toucan/services/auth.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ScrollController _scrollController = ScrollController();
  bool lastStatus = true;
  double height = 220;
  bool _isAnimating = false;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    print("before init in dashboard");
    _scrollController.addListener(_scrollListener);
    _scrollController.addListener(_setOffset);
    print("after init in dashboard");
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
    print("before _scrollListener in dashboard");
    _scrollController.removeListener(_scrollListener);
    print("before _setOffset in dashboard");
    _scrollController.removeListener(_setOffset);
    print("before _scrollListener in dashboard");
    _scrollController.dispose();
    super.dispose();
    print("dispose in dashboard");
  }

  showCreateGoalSheet() {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Color.fromARGB(85, 0, 0, 0),
        enableDrag: false,
        context: context,
        builder: (BuildContext context) {
          return CreateGoal();
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
    return Scaffold(
      body: AbsorbPointer(
        absorbing: _isAnimating,
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
                  background: PageHeader(today: today),
                ),
              ),
            ];
          },
          body: GoalsListView(),
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

class GoalsListView extends StatelessWidget {
  const GoalsListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 36, 16, 70),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Card(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    onTap: () {},
                    title: Text(
                      "Goal ${index + 1}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        fontSize: 20,
                      ),
                    ),
                    visualDensity: VisualDensity(vertical: 4),
                  ),
                );
              },
              childCount: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.today,
  });

  final DateTime today;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.orange,
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateFormat('MMMM dd').format(today)}',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    fontSize: 48,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    backgroundImage: Image.asset(
                      "assets/temp-img1.png",
                      fit: BoxFit.cover,
                    ).image,
                    radius: MediaQuery.of(context).size.width * .125,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis p',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
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
          color: Colors.orange,
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
