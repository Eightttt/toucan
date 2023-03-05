import 'package:flutter/material.dart';
import 'package:toucan/pages/landing.dart';

void main() {
  MaterialColor mainAppColor = const MaterialColor(0xF28705FF, <int, Color> {
    50: Color(0xFFF28705),
    100: Color(0xFFF28705),
    200: Color(0xFFF28705),
    300: Color(0xFFF28705),
    400: Color(0xFFF28705),
    500: Color(0xFFF28705),
    600: Color(0xFFF28705),
    700: Color(0xFFF28705),
    800: Color(0xFFF28705),
    900: Color(0xFFF28705),
  });

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: mainAppColor,
      scaffoldBackgroundColor: const Color(0xFFFDFDF5),
      fontFamily: 'Inter',

    ),
    initialRoute: '/',
    routes: {
      '/': (context) => const Landing(),
    }
  ));
}
