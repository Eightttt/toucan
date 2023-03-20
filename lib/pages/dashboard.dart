import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:toucan/pages/goals/createGoal.dart";

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DateTime today = new DateTime.now();
  List<String> goals = ['Fitness Goal', 'Book Club'];

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
      appBar: AppBar(
        toolbarHeight: 200,
        title: Align(
          alignment: Alignment.topLeft,
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(width:2, color: Color(0xFFFDFDF5)),
              borderRadius: const BorderRadius.all(const Radius.circular(50)),
              color: Color(0xFFFDFDF5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/temp-avi.jpg'),
                  radius: 50,
                ),
                SizedBox(width: 30),
                Column(
                  children: [
                    Text(
                      '${DateFormat('MMMM dd').format(today)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 36,
                      ),
                    ),
                    Text(
                      'Have a great day\n'
                      'Toucan!',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index){
                return Card(
                  child: ListTile(
                    onTap: () {},
                    title: Text(
                      goals[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    visualDensity: VisualDensity(vertical: 4),
                  ),
                );
              }
            ),
          ),
          ElevatedButton(
              onPressed: () {
                showCreateGoalSheet();
              },
              child: Icon(
                Icons.add_box_rounded,
                size: 30,
              )
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Calendar',
            backgroundColor: Color(0xFFFDFDF5),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Color(0xFFFDFDF5),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Friends',
            backgroundColor: Color(0xFFFDFDF5),
          ),
        ],
      ),
    );
  }
}
