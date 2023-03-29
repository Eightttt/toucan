import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    super.key,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(color: Color.fromARGB(69, 0, 0, 0), blurRadius: 10)
      ]),
      child: BottomNavigationBar(
        onTap: (index) => setState(() => currentIndex = index),
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
    );
  }
}