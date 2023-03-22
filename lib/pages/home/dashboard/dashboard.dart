import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:toucan/pages/home/dashboard/creategoal.dart';
import "package:toucan/pages/home/dashboard/fadeappbar.dart";

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ScrollController _scrollController = ScrollController();
  bool lastStatus = true;
  double height = 200;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  bool get _isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > (height - kToolbarHeight);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  showCreateGoalSheet() {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
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

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 5,
              pinned: true,
              expandedHeight: MediaQuery.of(context).size.height * 0.25,
              title: FadingAppBar(
                scrollController: _scrollController,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/toucan-title-logo.png",
                      fit: BoxFit.fitHeight,
                      height: AppBar().preferredSize.height,
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
            Text(
              'USER EDITABLE TEXT',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
