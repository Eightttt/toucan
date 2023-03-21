import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toucan/pages/authenticate/welcome.dart';
import 'package:toucan/pages/home/home.dart';
import 'package:toucan/models/userModel.dart';

class Landing extends StatelessWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    return user == null ? Welcome() : Home();
  }
}
