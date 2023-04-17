import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toucan/pages/authenticate/confirmation.dart';
import 'package:toucan/pages/authenticate/welcome.dart';
import 'package:toucan/models/userModel.dart';
import 'package:toucan/pages/home/home.dart';


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
            : Home(uid: uid!);
  }
}
