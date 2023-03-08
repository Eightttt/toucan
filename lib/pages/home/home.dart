import "package:flutter/material.dart";
import 'package:toucan/services/auth.dart';

class Home extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: ElevatedButton(
              onPressed: () async {
                await _authService.logout();
              },
              child: Text("Log-out")),
        ));
  }
}
