import 'package:flutter/material.dart';
import 'package:toucan/services/auth.dart';
import 'package:toucan/shared/loading.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final AuthService _authService = AuthService();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String email = "";
  String password = "";

  void showLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  logInUser() async {
    final isValid = formKey.currentState?.validate();
    if (isValid!) {
      formKey.currentState!.save();
      showLoading();
      dynamic result = await _authService.login(email, password);
      showLoading();

      if (result == null) {
        final snackBar = SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Invalid log-in credentials",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFFD74714),
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 80,
              left: 47,
              right: 47),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        // CLose modal bottom sheet
        Navigator.of(context).pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Form(
            key: formKey,
            child: Container(
              margin: const EdgeInsets.fromLTRB(47, 0, 47, 0),
              height: MediaQuery.of(context).size.height * 0.5,
              child: ListView(
                children: [
                  // ======== EMAIL ========
                  Container(
                      margin: EdgeInsets.fromLTRB(
                          10, MediaQuery.of(context).size.height * 0.05, 0, 6),
                      child: const Text(
                        'E-mail',
                        style: TextStyle(
                          color: Color(0xfff28705),
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                  TextFormField(
                    decoration: const InputDecoration(
                      errorMaxLines: 3,
                      prefixIcon: Padding(
                        padding: EdgeInsets.fromLTRB(12, 0, 10, 0),
                        child: Icon(
                          Icons.email_outlined,
                          size: 21,
                        ),
                      ),
                    ),
                    validator: (value) {
                      const pattern =
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                      final regEx = RegExp(pattern);
                      if (!regEx.hasMatch(value!)) {
                        return 'Invalid email';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) => email = value!,
                  ),

                  // ======== PASSWORD ========
                  Container(
                      margin: const EdgeInsets.fromLTRB(10, 10, 0, 6),
                      child: const Text(
                        'Password',
                        style: TextStyle(
                          color: Color(0xfff28705),
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      errorMaxLines: 3,
                      prefixIcon: Padding(
                        padding: EdgeInsets.fromLTRB(12, 0, 10, 0),
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 21,
                        ),
                      ),
                    ),
                    onSaved: (value) => password = value!,
                  ),

                  // ======== FORGOT PASSWORD ========
                  Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                    child: TextButton(
                        style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            )),
                        onPressed: () async {
                          // TODO: Add forgot password feature
                          Navigator.of(context).pop(context);
                        },
                        child: const Text('Forgot Password?')),
                  ),

                  // ======== ENTER BUTTON ========
                  SizedBox(height: MediaQuery.of(context).size.height * 0.045),
                  ElevatedButton(
                      onPressed: logInUser, child: const Text('Enter')),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.045)
                ],
              ),
            ),
          ),
          Positioned(
              bottom: MediaQuery.of(context).size.height * .5 - 20,
              child: Visibility(visible: isLoading, child: Loading(size: 40))),
        ]);
  }
}
