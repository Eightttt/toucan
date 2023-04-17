import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toucan/firebase_options.dart';
import 'package:toucan/pages/landing.dart';
import 'package:toucan/models/userModel.dart';
import 'package:toucan/services/auth.dart';
import 'package:toucan/services/notification.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().requestPermissions();
  NotificationService().initializeNotif();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const MaterialColor mainAppColor = MaterialColor(0xfff28705, <int, Color>{
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

  runApp(ToucanApp(mainAppColor: mainAppColor, toucanWhite: toucanWhite));
}

class ToucanApp extends StatelessWidget {
  const ToucanApp({
    super.key,
    required this.mainAppColor,
    required this.toucanWhite,
  });

  final MaterialColor mainAppColor;
  final Color toucanWhite;

  @override
  Widget build(BuildContext context) {
    precacheImage(Image.asset('assets/toucan-title-logo.png').image, context);
    precacheImage(Image.asset('assets/preview.png').image, context);
    precacheImage(Image.asset('assets/confirmation.png').image, context);
    return StreamProvider<UserModel?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: mainAppColor,
          scaffoldBackgroundColor: toucanWhite,
          fontFamily: 'Inter',
          iconTheme: IconThemeData(color: mainAppColor),
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: toucanWhite,
            elevation: 30,
            modalBarrierColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
          ),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.only(left: 15, right: 15),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(double.infinity, 44),
              elevation: 8,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 19,
                letterSpacing: 0.5,
              ),
              foregroundColor: toucanWhite,
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: toucanWhite,
            backgroundColor: mainAppColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          cardTheme: CardTheme(
            color: toucanWhite,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedIconTheme: IconThemeData(color: mainAppColor),
            unselectedIconTheme: IconThemeData(color: Colors.black),
            backgroundColor: toucanWhite,
            elevation: 0,
          ),
        ),
        home: Landing(),
      ),
    );
  }
}
