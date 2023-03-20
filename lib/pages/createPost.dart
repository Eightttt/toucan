import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({Key? key}) : super(key: key);

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  _MyFormState(){
    chosenValue = goals[0];
  }
  final goals = ["Academic", "Work", "Personal"];
  String? chosenValue = "Academic";

  TextEditingController _targetDate = TextEditingController();

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
                        hint: Text("Goal: "),
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
                    TextFormField(
                      decoration: InputDecoration(hintText: "Target Date:"),
                      controller: _targetDate,
                      onTap: () async{
                        DateTime? pickeddate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2200));
                        if(pickeddate != null){
                          _targetDate.text = DateFormat('MMMM-dd-yyyy').format(pickeddate);
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
      ),
    );
  }
}
