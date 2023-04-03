import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:toucan/models/goalModel.dart';
import 'package:toucan/services/database.dart';

class EditGoal extends StatefulWidget {
  final String uid;
  final GoalModel? goal;
  const EditGoal({Key? key, required this.uid, required this.goal})
      : super(key: key);

  @override
  State<EditGoal> createState() => _EditGoalState();
}

class _EditGoalState extends State<EditGoal> {
  final formKeyGoal = GlobalKey<FormState>();

  final _goalTags = ["Academic", "Work", "Personal"];
  final _frequency = ["day/s", "week/s", "month/s", "year/s"];
  late DateTime _startDate;
  late DateTime _endDate;

  String _goalTitle = "";
  String _chosenGoalTag = "Academic";
  TextEditingController _startEndDate = TextEditingController();
  int _period = 1;
  String _chosenFrequency = "day/s";
  String? _description;

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(Duration(days: 7)),
  );

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _chosenGoalTag = widget.goal!.tag;
      _period = widget.goal!.period;
      _chosenFrequency = widget.goal!.frequency;
      _dateRange = DateTimeRange(
          start: widget.goal!.startDate, end: widget.goal!.endDate);
      _startEndDate.text =
          DateFormat('MMMM dd, yyyy').format(_dateRange.start) +
              " - " +
              DateFormat('MMMM dd, yyyy').format(_dateRange.end);
      _description = widget.goal!.description;
    }
    ;
  }

  saveGoal() {
    final isValid = formKeyGoal.currentState?.validate();
    if (isValid != null && isValid) {
      formKeyGoal.currentState!.save();
      DatabaseService(uid: widget.uid).updateGoalData(
        widget.goal?.id,
        _goalTitle,
        _chosenGoalTag,
        _startDate,
        _endDate,
        _period,
        _chosenFrequency,
        _description ?? "Page description",
        false,
      );
      Navigator.of(context).pop();
    } else {
      print("error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))
          //more than 50% of width makes circle
          ),
      margin: EdgeInsets.only(left: 15, right: 15),
      height: widget.goal != null
          ? MediaQuery.of(context).size.height * 0.8
          : MediaQuery.of(context).size.height * 0.65,
      child: Form(
        key: formKeyGoal,
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
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // GOAL TITLE
                  TextFormField(
                    initialValue: widget.goal?.title,
                    maxLength: 20,
                    decoration: InputDecoration(hintText: "Goal Title:"),
                    validator: (value) {
                      if (value!.length <= 0) {
                        return 'Title cannot be empty';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) => _goalTitle = value!,
                  ),

                  // ==== GOAL TAG ====
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 8),
                    alignment: Alignment.topLeft,
                    child: Text("Goal Tag"),
                  ),
                  DropdownButtonFormField(
                    isExpanded: true,
                    value: _chosenGoalTag,
                    items: _goalTags
                        .map((e) => DropdownMenuItem(
                              child: Text(e),
                              value: e,
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _chosenGoalTag = val as String;
                      });
                    },
                    onSaved: (value) => _chosenGoalTag = value!,
                    validator: (value) {
                      if (value!.length <= 0) {
                        return 'Choose a goal tag';
                      } else {
                        return null;
                      }
                    },
                  ),

                  // ==== GOAL DURATION ====
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 20, 0, 8),
                    alignment: Alignment.topLeft,
                    child: Text("Goal Duration"),
                  ),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Start Date - End Date",
                      errorMaxLines: 3,
                    ),
                    controller: _startEndDate,
                    onTap: () async {
                      DateTimeRange? pickedDateRange =
                          await showDateRangePicker(
                              context: context,
                              initialDateRange: _dateRange,
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2200));
                      if (pickedDateRange != null) {
                        _dateRange = pickedDateRange;
                        _startEndDate.text = DateFormat('MMMM dd, yyyy')
                                .format(_dateRange.start) +
                            " - " +
                            DateFormat('MMMM dd, yyyy').format(_dateRange.end);
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
                      _startDate = _dateRange.start;
                      _endDate = _dateRange.end;
                    },
                  ),
                  SizedBox(width: 20),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 20, 0, 8),
                    alignment: Alignment.topLeft,
                    child: Text("Notify every"),
                  ),

                  // ==== Notification interval ====
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                            initialValue: "${_period}",
                            onChanged: (number) {
                              if (number.length > 0) {
                                setState(() => _period = int.parse(number));
                                // TODO: test this without onchanged but onsaved
                              } else {
                                setState(() => _period = 1);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "1",
                              errorMaxLines: 3,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            validator: (value) {
                              if (value!.length == 0) {
                                return 'Enter number';
                              } else if (value == 0) {
                                return 'Must be greater than 0';
                              } else {
                                return null;
                              }
                            }),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          value: _chosenFrequency,
                          items: _frequency
                              .map((e) => DropdownMenuItem(
                                    child: Text(e),
                                    value: e,
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _chosenFrequency = val as String;
                            });
                          },
                          validator: (value) {
                            if (value!.length <= 0) {
                              return 'Interval cannot be empty';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) => _chosenFrequency = value!,
                        ),
                      ),
                    ],
                  ),

                  // ==== DESCRIPTION ====
                  if (widget.goal != null) SizedBox(width: 20),
                  if (widget.goal != null)
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 20, 0, 8),
                      alignment: Alignment.topLeft,
                      child: Text("Description"),
                    ),
                  if (widget.goal != null)
                    TextFormField(
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      initialValue: _description,
                      maxLength: 56,
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          int newLines = newValue.text.split('\n').length;
                          if (newLines > 3) {
                            return oldValue;
                          } else {
                            return newValue;
                          }
                        }),
                      ],
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(15),
                        errorMaxLines: 3,
                      ),
                      validator: (value) {
                        if (value!.length == 0) {
                          return 'Must not be empty';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) => _description = value!,
                    ),

                  // ==== Confirm Button ====
                  SizedBox(height: 45),
                  Row(
                    children: [
                      Expanded(flex: 5, child: SizedBox()),
                      Expanded(
                        flex: 4,
                        child: ElevatedButton(
                            onPressed: () => saveGoal(),
                            child:
                                Text(widget.goal != null ? "Save" : "Confirm")),
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
