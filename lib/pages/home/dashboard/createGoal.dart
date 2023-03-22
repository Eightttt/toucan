import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class CreateGoal extends StatefulWidget {
  const CreateGoal({Key? key}) : super(key: key);

  @override
  State<CreateGoal> createState() => _CreateGoalState();
}

class _CreateGoalState extends State<CreateGoal> {
  final formKeyGoal = GlobalKey<FormState>();

  final _goalTags = ["Academic", "Work", "Personal"];
  final _interval = ["day/s", "week/s", "month/s", "year/s"];

  String _goalTitle = "";
  String _chosenGoalTag = "Academic";
  TextEditingController _startDate = TextEditingController();
  TextEditingController _endDate = TextEditingController();
  int period = 1;
  String _chosenInterval = "day/s";

  @override
  void initState() {
    super.initState();
  }

  saveGoal() {
    final isValid = formKeyGoal.currentState?.validate();
    if (isValid != null && isValid) {
      formKeyGoal.currentState!.save();
      print("Title: ${_goalTitle}");
      print("Goal Tag: ${_chosenGoalTag}");
      print("Start Date: ${_startDate.text}");
      print("End Date: ${_endDate.text}");
      print("Period: ${period}");
      print("Chosen Interval: ${_chosenInterval}");
    } else {
      print("error");
    }
    // TODO: Save goal into databse
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKeyGoal,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
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
                  SizedBox(height: 20),

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
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text("Goal Duration"),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        // GOAL DURATION
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(hintText: "Start Date:"),
                          controller: _startDate,
                          onTap: () async {
                            DateTime? pickeddate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2200));
                            if (pickeddate != null) {
                              _startDate.text =
                                  DateFormat('MMMM-dd-yyyy').format(pickeddate);
                            }
                          },
                          validator: (value) {
                            if (value!.length <= 0) {
                              return 'Choose a date to start';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) => _startDate.text = value!,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(hintText: "End Date:"),
                          controller: _endDate,
                          onTap: () async {
                            DateTime? pickeddate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime(2200));
                            if (pickeddate != null) {
                              _endDate.text =
                                  DateFormat('MMMM-dd-yyyy').format(pickeddate);
                            }
                          },
                          validator: (value) {
                            if (value!.length <= 0) {
                              return 'Choose a date to end';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) => _endDate.text = value!,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text("Notify every"),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        // Notification interval
                        child: TextFormField(
                            initialValue: "${period}",
                            onChanged: (number) {
                              if (number.length > 0) {
                                setState(() => period = int.parse(number));
                              } else {
                                setState(() => period = 1);
                              }
                            },
                            decoration: InputDecoration(hintText: "1"),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            validator: (value) {
                              if (value!.length == 0) {
                                return 'Enter a number';
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
                          value: _chosenInterval,
                          items: _interval
                              .map((e) => DropdownMenuItem(
                                    child: Text(e),
                                    value: e,
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _chosenInterval = val as String;
                            });
                          },
                          validator: (value) {
                            if (value!.length <= 0) {
                              return 'Interval cannot be empty';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) => _chosenInterval = value!,
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
