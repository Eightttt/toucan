import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toucan/models/userDataModel.dart';
import 'package:toucan/pages/authenticate/confirmation.dart';
import 'package:toucan/pages/authenticate/welcome.dart';
import 'package:toucan/models/userModel.dart';
import 'package:toucan/pages/home/dashboard/dashboard.dart';

import '../models/goalModel.dart';
import '../services/database.dart';

class Landing extends StatefulWidget {
  Landing({Key? key}) : super(key: key);

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  bool _isFirstTimeLogin = false;

  void toggleIsFirstTimeLogin() {
    setState(() {
      _isFirstTimeLogin = !_isFirstTimeLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = Provider.of<UserModel?>(context);
    final String? uid = user?.uid;

    return user == null
        ? Welcome(toggleIsFirstTimeLogin: toggleIsFirstTimeLogin)
        : _isFirstTimeLogin
            ? Confirmation(toggleIsFirstTimeLogin: toggleIsFirstTimeLogin)
            : MultiProvider(
                providers: [
                  StreamProvider<List<GoalModel>?>.value(
                    value: DatabaseService(uid: uid).goals,
                    initialData: null,
                  ),
                  StreamProvider<UserDataModel?>.value(
                    value: DatabaseService(uid: uid).userData,
                    initialData: null,
                  ),
                ],
                child: Dashboard(
                  uid: uid!,
                ),
              );
  }
}
