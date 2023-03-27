import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:toucan/services/database.dart';

class CreateGoal extends StatefulWidget {
  final String uid;
  const CreateGoal({Key? key, required this.uid}) : super(key: key);

  @override
  State<CreateGoal> createState() => _CreateGoalState();
}

class _CreateGoalState extends State<CreateGoal> {
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

  DateTimeRange dateRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now().add(Duration(days: 7)),
  );

  @override
  void initState() {
    super.initState();
  }

  saveGoal() {
    final isValid = formKeyGoal.currentState?.validate();
    if (isValid != null && isValid) {
      formKeyGoal.currentState!.save();
      DatabaseService(uid: widget.uid).updateGoalData(
        _goalTitle,
        _chosenGoalTag,
        _startDate,
        _endDate,
        _period,
        _chosenFrequency,
        "Page description",
        false,
      );
      Navigator.of(context).pop();
    } else {
      print("error");
    }
    // TODO: Save goal into databse
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
      height: MediaQuery.of(context).size.height * 0.65,
      child: Form(
        key: formKeyGoal,
        child: ListView(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                color: Colors.orange,
                padding: EdgeInsets.only(left: 20, top: 20),
                iconSize: 30,
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.chevron_left),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // GOAL TITLE
                  TextFormField(
                    maxLength: 20,
                    decoration: InputDecoration(hintText: "Title:"),
                    validator: (value) {
                      if (value!.length <= 0) {
                        return 'Title cannot be empty';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) => _goalTitle = value!,
                  ),
                  SizedBox(height: 15),

                  // GOAL TAG
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
                              initialDateRange: dateRange,
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2200));
                      if (pickedDateRange != null) {
                        setState(() {});
                        dateRange = pickedDateRange;
                        _startDate = dateRange.start;
                        _endDate = dateRange.end;
                        _startEndDate.text =
                            DateFormat('MMMM dd, yyyy').format(_startDate) +
                                " - " +
                                DateFormat('MMMM dd, yyyy').format(_endDate);
                      }
                    },
                    validator: (value) {
                      if (value!.length <= 0) {
                        return 'Choose a date';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) => _startEndDate.text = value!,
                  ),
                  SizedBox(width: 20),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 20, 0, 8),
                    alignment: Alignment.topLeft,
                    child: Text("Notify every"),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        // Notification interval
                        child: TextFormField(
                            initialValue: "${_period}",
                            onChanged: (number) {
                              if (number.length > 0) {
                                setState(() => _period = int.parse(number));
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
                  SizedBox(height: 45),
                  Row(
                    children: [
                      Expanded(flex: 5, child: SizedBox()),
                      Expanded(
                        flex: 4,
                        child: ElevatedButton(
                            onPressed: saveGoal, child: const Text("Confirm")),
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
