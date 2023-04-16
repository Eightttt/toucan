import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:table_calendar/table_calendar.dart';
import 'package:toucan/models/taskModel.dart';

class Calendar extends StatefulWidget {
  Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  //This is the selected date which will be used to query tasks. If adding tasks, this will be passed to the editPost sheet to add a new Post
  DateTime today = DateTime.now();
  //Date today

  final _taskListTags = ["Today", "Past", "Upcoming"];
  String _chosenTaskListTag = "Today";

  //Dummy List
  List<TaskModel> _pastTasks = [
    TaskModel(DateTime.now().subtract(Duration(days: 5)), "Task 6", false),
    TaskModel(DateTime.now().subtract(Duration(days: 1)), "Task 8", true),
    TaskModel(DateTime.now().subtract(Duration(days: 3)), "Task 9", false),
  ];

  //Dummy List
  List<TaskModel> _currentTasks = [
    TaskModel(DateTime.now(), "Task 2", false),
    TaskModel(DateTime.now(), "Task 4", true),
    TaskModel(DateTime.now(), "Task 7", false),
  ];

  //Dummy List
  List<TaskModel> _upcomingTasks = [
    TaskModel(DateTime.now().add(Duration(days: 1)), "Task 1", true),
    TaskModel(DateTime.now().add(Duration(days: 3)), "Task 3", false),
    TaskModel(DateTime.now().add(Duration(days: 27)), "Task 5", true),
  ];

  // Current list of tasks being viewed by user
  List<TaskModel>? _viewedTasks;

  //Boolean for task complete or not
  bool status = false;

  @override
  void initState() {
    super.initState();
    _viewedTasks = _upcomingTasks;
  }

  List<TaskModel> getTasksList(String taskTag) {
    if (taskTag == "Past") return _pastTasks;
    if (taskTag == "Upcoming") return _upcomingTasks;
    return _currentTasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image(
              image: AssetImage("assets/toucan-title-logo.png"),
              height: kToolbarHeight,
              fit: BoxFit.fitHeight,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.add_circle_outline_rounded),
              color: Color(0xfff28705),
              iconSize: 35,
            ),
          ],
        ),
        backgroundColor: Color(0xFFFDFDF5),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(20, 10, 10, 5),
              child: Text(
                '${DateFormat('MMMM, yyyy').format(today)}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
              child: TableCalendar(
                rowHeight: 40,
                headerStyle: HeaderStyle(
                    formatButtonVisible: false, titleCentered: true),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day) => isSameDay(day, today),
                focusedDay: today,
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2100, 1, 1),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Color(0xfff28705),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: Color.fromARGB(69, 0, 0, 0), blurRadius: 5)
                  ],
                  color: Color(0xFFFDFDF5),
                ),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.fromLTRB(25, 20, 10, 10),
                      child: DropdownButton(
                        isDense: true,
                        dropdownColor: Color(0xFFFDFDF5),
                        value: _chosenTaskListTag,
                        items: _taskListTags
                            .map(
                              (taskTag) => DropdownMenuItem(
                                child: Container(
                                  color: Color(0xFFFDFDF5),
                                  child: Text(
                                    taskTag,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                value: taskTag,
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(
                            () {
                              _chosenTaskListTag = val as String;
                              _viewedTasks = getTasksList(_chosenTaskListTag);
                            },
                          );
                        },
                        underline: SizedBox(),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _viewedTasks!.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onTap: () {
                                setState(() {
                                  // TODO: update database, replace setter
                                  _viewedTasks![index].isDone =
                                      !_viewedTasks![index].isDone;
                                });
                              },
                              leading: Icon(
                                (_viewedTasks![index].isDone == false)
                                    ? Icons.circle_outlined
                                    : Icons.check_circle_outline,
                                color: Color(0xfff28705),
                              ),
                              title: Text(
                                _viewedTasks![index].task,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              selectedTileColor: Color(0xFF84C35D),
                              selectedColor: Color(0xFFFDFDF5),
                              selected: _viewedTasks![index].isDone,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                onPressed: () {}, icon: Icon(Icons.calendar_today_rounded)),
            IconButton(
                onPressed: () {},
                icon: Icon(Icons.home_rounded),
                color: Colors.grey),
            IconButton(
                onPressed: () {},
                icon: Icon(Icons.people_alt_rounded),
                color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
