import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:toucan/pages/goals/createGoal.dart";
import "package:toucan/pages/createPost.dart";

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DateTime today = new DateTime.now();
  int currentIndex = 1;

  showCreateGoalSheet() {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        enableDrag: false,
        context: context,
        builder: (BuildContext context) {
          return CreateGoal();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (BuildContext context, bool isScrolled) {
            return [
              SliverAppBar(
                snap: true,
                floating: true,
                toolbarHeight: MediaQuery.of(context).size.height * 0.25,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              )
            ];
          },
          body: ListView.builder(
              padding: EdgeInsets.fromLTRB(16, 39, 16, 70),
              itemCount: 20,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    onTap: () {},
                    title: Text(
                      "Goal ${index + 1}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    visualDensity: VisualDensity(vertical: 4),
                  ),
                );
              })),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showCreateGoalSheet();
          },
          child: Icon(
            Icons.add,
          )),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: <BoxShadow>[
          BoxShadow(color: Color.fromARGB(69, 0, 0, 0), blurRadius: 10)
        ]),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
