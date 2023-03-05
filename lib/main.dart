import 'package:flutter/material.dart';
import 'package:toucan/pages/landing.dart';

void main() {
  const MaterialColor mainAppColor = MaterialColor(0xfff28705, <int, Color> {
    50: Color(0xfff28705),
    100: Color(0xfff28705),
    200: Color(0xfff28705),
    300: Color(0xfff28705),
    400: Color(0xfff28705),
    500: Color(0xfff28705),
    600: Color(0xfff28705),
    700: Color(0xfff28705),
    800: Color(0xfff28705),
    900: Color(0xfff28705),
  });

  const Color toucanWhite = Color(0xFFFDFDF5);

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: mainAppColor,
      scaffoldBackgroundColor: toucanWhite,
      fontFamily: 'Inter',
      iconTheme: const IconThemeData(color: mainAppColor),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: toucanWhite,
        elevation: 20,
        modalBarrierColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(36))
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mainAppColor),
          borderRadius: BorderRadius.all(Radius.circular(17)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        prefixIconColor: mainAppColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 58),
          elevation: 8,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 19,
            letterSpacing: 0.5,
          ),
          foregroundColor: toucanWhite,
        ),
      ),

    ),
    initialRoute: '/',
    routes: {
      '/': (context) => const Landing(),
    }
  ));
}
