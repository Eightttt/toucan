import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toucan/pages/home/dashboard/editPost.dart';
import 'package:toucan/models/dummyModelforCalendar.dart';

class Calendar extends StatefulWidget {
  Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  //This is the selected date which will be used to query tasks. If adding tasks, this will be passed to the editPost sheet to add a new Post
  DateTime today = DateTime.now();
  //Date today
  DateTime todayStatic = DateTime.now();
  //Function for selecting a day and updating the "today" variable
  void _onDaySelected(DateTime day, DateTime focusedDay){
    setState(() {
      today = day;
    });
  }
  //Dummy List
  List<DummyModel> tasks = [
    DummyModel(task: "Task 1", status: false),
    DummyModel(task: "Task 2", status: false),
    DummyModel(task: "Task 3", status: true),
  ];
  //Boolean for task complete or not
  bool status = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image(
              image: AssetImage("assets/toucan-title-logo.png"),
              width:150,
              height:100,
            ),
            SizedBox(width: 170),
            IconButton(
                onPressed: () {},
                icon: Icon(Icons.add_circle_outline),
                color: Color(0xfff28705),
            ),
          ],
        ),
        backgroundColor: Color(0xFFFDFDF5),
        toolbarHeight: 75,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child:
                Container(
                  child:
                    Text(
                        '${DateFormat('MMMM dd').format(todayStatic)}',
                        style:TextStyle(
                          fontSize: 30,
                        ),
                    ),
                    padding: EdgeInsets.fromLTRB(30, 0, 10, 0),
                ),
            ),
            TableCalendar(
              rowHeight: 40,
              headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day,today),
              focusedDay: today,
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2100, 1, 1),
              onDaySelected: _onDaySelected,
            ),
            Divider(
              height: 30,
              color: Colors.grey[900],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child:
              Container(
                child:
                Text(
                  'Today',
                  style:TextStyle(
                    fontSize: 30,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(30, 0, 10, 0),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index){
                  return Card(
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          tasks[index].status = !tasks[index].status;
                        });
                      },
                        leading: Icon((tasks[index].status == false) ? Icons.circle_outlined : Icons.check_circle_outline),
                        title: Text(tasks[index].task),
                    selectedTileColor: Colors.lightGreen,
                    selectedColor: Colors.white,
                    selected: tasks[index].status,
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.calendar_today_rounded)),
            IconButton(onPressed: () {}, icon: Icon(Icons.home_rounded), color: Colors.grey),
            IconButton(onPressed: () {}, icon: Icon(Icons.people_alt_rounded), color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
