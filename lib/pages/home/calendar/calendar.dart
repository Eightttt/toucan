import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'package:table_calendar/table_calendar.dart';
import 'package:toucan/models/taskModel.dart';
import 'package:toucan/pages/home/calendar/editTask.dart';
import 'package:toucan/services/database.dart';
import 'package:toucan/shared/loading.dart';

class Calendar extends StatefulWidget {
  final String? uid;

  // TODO: remove ""
  Calendar({Key? key, this.uid = ""}) : super(key: key);

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
    TaskModel(
        "fakeid", DateTime.now().subtract(Duration(days: 5)), "Task 6", false),
    TaskModel(
        "fakeid", DateTime.now().subtract(Duration(days: 1)), "Task 8", true),
    TaskModel(
        "fakeid", DateTime.now().subtract(Duration(days: 3)), "Task 9", false),
  ];

  //Dummy List
  List<TaskModel> _currentTasks = [
    TaskModel("fakeid", DateTime.now(), "Task 2", false),
    TaskModel("fakeid", DateTime.now(), "Task 4", true),
    TaskModel("fakeid", DateTime.now(), "Task 7", false),
  ];

  //Dummy List
  List<TaskModel> _upcomingTasks = [
    TaskModel("fakeid", DateTime.now().add(Duration(days: 1)), "Task 1", true),
    TaskModel("fakeid", DateTime.now().add(Duration(days: 3)), "Task 3", false),
    TaskModel("fakeid", DateTime.now().add(Duration(days: 27)), "Task 5", true),
  ];

  // Current list of tasks being viewed by user
  List<TaskModel>? _viewedTasks;

  //Boolean for task complete or not
  bool status = false;

  Color toucanOrange = Color(0xfff28705);
  Color toucanWhite = Color(0xFFFDFDF5);

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

  void showAddNewTask(TaskModel? task) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Color.fromARGB(85, 0, 0, 0),
      enableDrag: false,
      context: context,
      builder: (context) => EditTask(task),
    );
  }

  showConfirmDeleteTask(String uid, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          iconPadding: EdgeInsets.only(top: 30, bottom: 10),
          icon: Icon(
            Icons.error_outline_rounded,
            size: 70,
          ),
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Are you sure?\n",
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              children: [
                WidgetSpan(child: SizedBox(height: 30)),
                TextSpan(
                  text:
                      "Do you really want to delete this task? This process cannot be undone.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(183, 91, 91, 91),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.only(bottom: 40),
          actions: [
            SizedBox(height: 10),
            Row(
              children: [
                Spacer(flex: 1),
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      side: BorderSide(width: 1, color: toucanOrange),
                      backgroundColor: toucanWhite,
                      foregroundColor: toucanOrange,
                      minimumSize: const Size(120, 33),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Spacer(flex: 1),
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDeletingTaskDialog(uid, task);
                    },
                    child: Text(
                      "Delete",
                      style: TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      side: BorderSide(width: 1, color: toucanOrange),
                      backgroundColor: toucanOrange,
                      minimumSize: const Size(120, 33),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Spacer(flex: 1),
              ],
            )
          ],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
        );
      },
    );
  }

  void showDeletingTaskDialog(String uid, TaskModel task) async {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            titlePadding: EdgeInsets.fromLTRB(29, 50, 29, 40),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ==== Deleting Progress Indicator ====
                Loading(size: 40),
                Container(
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    'Task: "${task.title}"\nDeleting task\'s data...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      height: 2,
                    ),
                  ),
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
          ),
        );
      },
    );
    // await DatabaseService(uid: uid).deleteTask(task.id);
    await Future.delayed(Duration(seconds: 7));
    Navigator.popUntil(context, (route) => route.isFirst);
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
              onPressed: () => showAddNewTask(null),
              icon: Icon(Icons.add_circle_outline_rounded),
              color: toucanOrange,
              iconSize: 35,
            ),
          ],
        ),
        backgroundColor: toucanWhite,
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
                firstDay: DateTime(2023),
                lastDay: DateTime(2200),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: toucanOrange,
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
                  color: toucanWhite,
                ),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.fromLTRB(25, 20, 10, 10),
                      child: DropdownButton(
                        isDense: true,
                        dropdownColor: toucanWhite,
                        value: _chosenTaskListTag,
                        items: _taskListTags
                            .map(
                              (taskTag) => DropdownMenuItem(
                                child: Container(
                                  color: toucanWhite,
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
                              ),
                              title: Text(
                                _viewedTasks![index].title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    iconSize: 30,
                                    onPressed: () =>
                                        showAddNewTask(_viewedTasks![index]),
                                    icon: Icon(
                                      Icons.edit_note_rounded,
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    iconSize: 25,
                                    onPressed: () => showConfirmDeleteTask(
                                        widget.uid!, _viewedTasks![index]),
                                    icon: Icon(
                                      Icons.delete_forever_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              iconColor: toucanOrange,
                              selectedTileColor: Color(0xFF84C35D),
                              selectedColor: toucanWhite,
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
