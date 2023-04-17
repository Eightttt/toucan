import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toucan/models/taskModel.dart';
import 'package:toucan/services/database.dart';

class EditTask extends StatefulWidget {
  final TaskModel? task;
  final String uid;

  const EditTask({
    required this.task,
    required this.uid,
  });

  updateTaskStatus(bool isDone) async {
    DatabaseService(uid: uid).updateTaskStatus(task!.id, isDone);
  }

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  final formKey = GlobalKey<FormState>();

  String _taskTitle = "";

  TextEditingController _chosenDateController = TextEditingController();

  DateTime _chosenDate = DateTime.now().add(Duration(days: 1));

  DateTime? _pickedDate;

  saveTask() async {
    final isValid = formKey.currentState?.validate();
    if (isValid!) {
      formKey.currentState!.save();

      DatabaseService(uid: widget.uid)
          .updateTaskData(widget.task?.id, _taskTitle, _chosenDate, false);
      print("Task title: $_taskTitle\nChosen date: $_chosenDate");

      Navigator.of(context).pop();
    } else {
      print("error");
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _chosenDateController.text =
          DateFormat('MMMM dd, yyyy').format(widget.task!.date);
      _pickedDate = widget.task!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xFFFDFDF5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))
          //more than 50% of width makes circle
          ),
      margin: EdgeInsets.only(left: 15, right: 15),
      height: MediaQuery.of(context).size.height * 0.48,
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                color: Colors.orange,
                padding: EdgeInsets.only(left: 20, top: 20),
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_ios_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // TASK TITLE
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 8),
                    alignment: Alignment.topLeft,
                    child: Text(widget.task != null
                        ? "Edit Task - ${widget.task!.title}"
                        : "New Task"),
                  ),
                  TextFormField(
                    initialValue: widget.task?.title,
                    maxLength: 50,
                    decoration: InputDecoration(hintText: "Title:"),
                    validator: (value) {
                      if (value!.length <= 0) {
                        return 'Title cannot be empty';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) => _taskTitle = value!,
                  ),

                  // ==== TASK DATE ====
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 0, 8),
                    alignment: Alignment.topLeft,
                    child: Text("Target Date"),
                  ),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Choose a date",
                      errorMaxLines: 3,
                    ),
                    controller: _chosenDateController,
                    onTap: () async {
                      _pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _pickedDate ?? DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2200),
                      );
                      if (_pickedDate != null) {
                        _chosenDateController.text =
                            DateFormat('MMMM dd, yyyy').format(_pickedDate!);
                      }
                    },
                    validator: (value) {
                      if (value!.length <= 0) {
                        return 'Choose a date';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      _chosenDate = _pickedDate!;
                    },
                  ),

                  // ==== BUTTONS ====
                  SizedBox(height: 45),
                  Row(
                    children: [
                      Spacer(flex: 6),
                      Expanded(
                        flex: 4,
                        child: ElevatedButton(
                            onPressed: () => saveTask(),
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                            ),
                            child:
                                Text(widget.task != null ? "Save" : "Confirm")),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
