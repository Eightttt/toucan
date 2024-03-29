import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toucan/models/goalModel.dart';
import 'package:toucan/models/postModel.dart';
import 'package:toucan/models/taskModel.dart';
import 'package:toucan/models/userDataModel.dart';
import 'package:toucan/pages/home/calendar/calendar.dart';
import 'package:toucan/pages/home/dashboard/dashboard.dart';
import 'package:toucan/pages/home/socials/socials.dart';
import 'package:toucan/services/database.dart';

class Home extends StatefulWidget {
  final String uid;
  const Home({super.key, required this.uid});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Color toucanOrange = Color(0xfff28705);
  Color toucanWhite = Color(0xFFFDFDF5);
  int currentIndex = 1;
  late List<Widget> pages;

  @override
  void initState() {
    pages = [
      // Calendar Page = 0
      MultiProvider(
        providers: [
          StreamProvider<List<TaskModel>?>.value(
            value: DatabaseService(uid: widget.uid).tasks,
            initialData: null,
            catchError: (context, error) {
              print("Error: $error");
              return null; // return a default value
            },
          ),
        ],
        child: Calendar(),
      ),

      // Dashboard Page = 1
      MultiProvider(
        providers: [
          StreamProvider<List<GoalModel>?>.value(
            value: DatabaseService(uid: widget.uid).goals,
            initialData: null,
            catchError: (context, error) {
              print("Error: $error");
              return null; // return a default value
            },
          ),
          StreamProvider<UserDataModel?>.value(
            value: DatabaseService(uid: widget.uid).userData,
            initialData: null,
            catchError: (context, error) {
              print("Error: $error");
              return null; // return a default value
            },
          ),
        ],
        child: Dashboard(),
      ),

      // Socials Page = 2
      MultiProvider(
        providers: [
          StreamProvider<List<PostModel>?>.value(
            value: DatabaseService(uid: widget.uid).followingsPosts,
            initialData: null,
            catchError: (context, error) {
              print("Error: $error");
              return null; // return a default value
            },
          ),
          StreamProvider<List<UserDataModel>?>.value(
            value: DatabaseService(uid: widget.uid).followingsUsersData,
            initialData: null,
            catchError: (context, error) {
              print("Error: $error");
              return null; // return a default value
            },
          ),
        ],
        child: StreamProvider<UserDataModel?>.value(
          value: DatabaseService(uid: widget.uid).userData,
          initialData: null,
          catchError: (context, error) {
            print("Error: $error");
            return null; // return a default value
          },
          child: Socials(),
        ),
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: <BoxShadow>[
          BoxShadow(color: Color.fromARGB(69, 0, 0, 0), blurRadius: 10)
        ]),
        child: BottomNavigationBar(
          onTap: (newIndex) => setState(() => currentIndex = newIndex),
          currentIndex: currentIndex,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Calendar',
              backgroundColor: Color(0xFFFDFDF5),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
              backgroundColor: Color(0xFFFDFDF5),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Socials',
              backgroundColor: Color(0xFFFDFDF5),
            ),
          ],
        ),
      ),
    );
  }
}
