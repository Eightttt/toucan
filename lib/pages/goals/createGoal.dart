import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateGoal extends StatefulWidget {
  const CreateGoal({Key? key}) : super(key: key);

  @override
  State<CreateGoal> createState() => _CreateGoalState();
}

class _CreateGoalState extends State<CreateGoal> {
  _MyFormState(){
    chosenValue = goals[0];
  }
  final goals = ["Academic", "Work", "Personal"];
  String? chosenValue = "Academic";

  TextEditingController _startDate = TextEditingController();
  TextEditingController _endDate = TextEditingController();
  TextEditingController _notificationDate = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor: Color(0xFFFDFDF5),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 50),
            Form(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(hintText: "Title:"),
                    ),
                    SizedBox(height: 20),
                    DropdownButton(
                      isExpanded:true,
                      hint: Text("Goal Tag:"),
                      value: chosenValue,
                      items: goals.map(
                        (e) => DropdownMenuItem(child: Text(e), value: e,)
                      ).toList(),
                      onChanged: (val){
                      setState(() {
                        chosenValue = val as String;
                      });
                      }
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Text("Goal Duration")),
                        Expanded(child: SizedBox(width: 20,)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(hintText: "Start Date:"),
                            controller: _startDate,
                            onTap: () async{
                              DateTime? pickeddate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2023),
                                  lastDate: DateTime(2200));
                              if(pickeddate != null){
                                _startDate.text = DateFormat('MMMM-dd-yyyy').format(pickeddate);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(hintText: "End Date:"),
                            controller: _endDate,
                            onTap: () async{
                              DateTime? pickeddate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2023),
                                  lastDate: DateTime(2200));
                              if(pickeddate != null){
                                _endDate.text = DateFormat('MMMM-dd-yyyy').format(pickeddate);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Text("Reminder Interval")),
                        Expanded(child: SizedBox(width: 20)),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(hintText: "Notification Date:"),
                      controller: _notificationDate,
                      onTap: () async{
                        DateTime? pickeddate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2200));
                        if(pickeddate != null){
                          _notificationDate.text = DateFormat('MMMM-dd-yyyy').format(pickeddate);
                        }
                      },
                    ),
                    SizedBox(height: 80),

                    Row(
                      children: [
                        Expanded(child: SizedBox(width: 40)),
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {},
                              child: Text("Confirm")),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
