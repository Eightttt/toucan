import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toucan/models/taskModel.dart';
import 'package:toucan/models/userModel.dart';
import 'package:toucan/pages/home/calendar/editTask.dart';
import 'package:toucan/services/database.dart';
import 'package:toucan/shared/loading.dart';

class Calendar extends StatefulWidget {
  Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  //This is the selected date which will be used to query tasks. If adding tasks, this will be passed to the editPost sheet to add a new Post
  DateTime today = DateTime.now();
  //Date today

  final _taskListTags = ["Past", "Today", "Upcoming"];
  String _chosenTaskListTag = "Today";

  // Current list of tasks being viewed by user
  List<TaskModel>? _viewedTasks;
  List<TaskModel>? _prevTasks;
  List<TaskModel>? pastTasks;
  List<TaskModel>? todayTasks;
  List<TaskModel>? upcomingTasks;

  bool isInitializedTasks = false;

  //Boolean for task complete or not
  bool status = false;

  Color toucanOrange = Color(0xfff28705);
  Color toucanWhite = Color(0xFFFDFDF5);

  @override
  void initState() {
    super.initState();
  }

  List<TaskModel> getTasksList(
    String taskTag,
    List<TaskModel> pastTasks,
    List<TaskModel> todayTasks,
    List<TaskModel> upcomingTasks,
  ) {
    if (taskTag == "Past") return pastTasks;
    if (taskTag == "Upcoming") return upcomingTasks;
    return todayTasks;
  }

  void showEditTask(TaskModel? task) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Color.fromARGB(85, 0, 0, 0),
      enableDrag: false,
      context: context,
      builder: (context) => EditTask(task: task),
    );
  }

  void updateStatus(String uid, TaskModel task, bool isDone) {
    EditTask(task: task).updateTaskStatus(uid, isDone);
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
    await DatabaseService(uid: uid).deleteTask(task.id);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final UserModel user = Provider.of<UserModel>(context);
    final List<TaskModel>? tasks = Provider.of<List<TaskModel>?>(context);

    if (tasks != null && tasks != _prevTasks) {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      pastTasks = tasks
          .where((task) => task.date.isBefore(startOfDay) && !task.isDone)
          .toList();
      todayTasks = tasks
          .where((task) =>
              !task.date.isBefore(startOfDay) && !task.date.isAfter(endOfDay))
          .toList();
      upcomingTasks =
          tasks.where((task) => task.date.isAfter(endOfDay)).toList();

      _viewedTasks = getTasksList(
          _chosenTaskListTag, pastTasks!, todayTasks!, upcomingTasks!);
      _prevTasks = tasks;
    }

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
              onPressed: () => showEditTask(null),
              icon: Icon(Icons.add_task_rounded),
              color: toucanOrange,
              iconSize: 35,
            ),
          ],
        ),
        backgroundColor: toucanWhite,
      ),
      body: pastTasks == null || todayTasks == null || upcomingTasks == null
          ? Container(
              color: Color(0xFFFDFDF5),
              child: Loading(size: 40),
            )
          : Center(
              child: Column(
                children: [
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
                          BoxShadow(
                              color: Color.fromARGB(69, 0, 0, 0), blurRadius: 5)
                        ],
                        color: toucanWhite,
                      ),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.fromLTRB(25, 20, 18, 15),
                            child: DropdownButton(
                              isDense: true,
                              dropdownColor: toucanWhite,
                              value: _chosenTaskListTag,
                              items: _taskListTags
                                  .map(
                                    (taskTag) => DropdownMenuItem(
                                      child: Container(
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
                                    _viewedTasks = getTasksList(
                                        _chosenTaskListTag,
                                        pastTasks!,
                                        todayTasks!,
                                        upcomingTasks!);
                                  },
                                );
                              },
                              underline: SizedBox(),
                            ),
                          ),
                          Divider(
                            height: 0,
                            thickness: 1,
                            indent: 15,
                            endIndent: 15,
                          ),
                          // List of Tasks
                          Expanded(
                            child: ListView.builder(
                              itemCount: _viewedTasks!.length == 0
                                  ? 1
                                  : _viewedTasks!.length,
                              itemBuilder: (context, index) {
                                return _viewedTasks!.length == 0

                                    // No tasks
                                    ? Text(
                                        "No tasks to be found here",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          height: 2,
                                        ),
                                      )

                                    // With Tasks
                                    : Card(
                                        margin: const EdgeInsets.fromLTRB(
                                            20, 10, 20, 10),
                                        child: ListTile(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              updateStatus(
                                                  user.uid,
                                                  _viewedTasks![index],
                                                  !_viewedTasks![index].isDone);
                                            });
                                          },
                                          leading: Center(
                                            widthFactor: 1,
                                            child: Icon(
                                              (_viewedTasks![index].isDone ==
                                                      false)
                                                  ? Icons.circle_outlined
                                                  : Icons.check_circle_outline,
                                            ),
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
                                                visualDensity:
                                                    VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                                iconSize: 30,
                                                onPressed: () => showEditTask(
                                                    _viewedTasks![index]),
                                                icon: Icon(
                                                  Icons.edit_note_rounded,
                                                ),
                                              ),
                                              IconButton(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                                iconSize: 25,
                                                onPressed: () =>
                                                    showConfirmDeleteTask(
                                                        user.uid,
                                                        _viewedTasks![index]),
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
    );
  }
}
