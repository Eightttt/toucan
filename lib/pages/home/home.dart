import "package:flutter/material.dart";
import 'package:toucan/services/auth.dart';

class Home extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              Text(
                'Home',
                style: TextStyle(
                  color: Color(0xfff28705),
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(
                    47, MediaQuery.of(context).size.height - 150, 47, 0),
                child: ElevatedButton(
                    onPressed: () async {
                      await _authService.logout();
                    },
                    child: Text("Log-out")),
              ),
            ],
          ),
        ));
  }
}
