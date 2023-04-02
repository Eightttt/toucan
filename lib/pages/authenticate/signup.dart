import 'package:flutter/material.dart';
import 'package:toucan/services/auth.dart';
import 'package:toucan/shared/loading.dart';

class SignUp extends StatefulWidget {
  final VoidCallback showLogInSheet;
  final VoidCallback toggleIsFirstTimeLogin;
  const SignUp(
      {required this.showLogInSheet,
      required this.toggleIsFirstTimeLogin,
      super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading = false;

  void showLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .9,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          ListView(
            children: [
              // ======== TITLE ========
              Container(
                  margin: EdgeInsets.fromLTRB(
                      0,
                      MediaQuery.of(context).size.height * .075,
                      0,
                      MediaQuery.of(context).size.height * .06),
                  alignment: Alignment.center,
                  child: const Text(
                    'Set-up your Account',
                    style: TextStyle(
                      color: Color(0xfff28705),
                      fontWeight: FontWeight.w700,
                      fontSize: 25,
                    ),
                  )),

              // ======== FORM ========
              SignUpForm(
                  showLoading: showLoading,
                  toggleIsFirstTimeLogin: widget.toggleIsFirstTimeLogin),

              // ======== ALREADY HAVE AN ACCOUNT ========
              Container(
                margin: EdgeInsets.fromLTRB(
                    0,
                    MediaQuery.of(context).size.height * .075,
                    0,
                    MediaQuery.of(context).size.height * .06),
                alignment: Alignment.center,
                child: TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop(context);
                      await Future.delayed(const Duration(milliseconds: 200),
                          widget.showLogInSheet);
                    },
                    child: const Text('Already have an account?')),
              )
            ],
          ),
          Positioned(
              bottom: MediaQuery.of(context).size.height * .5 - 20,
              child: Visibility(visible: isLoading, child: Loading(size: 40)))
        ],
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  final VoidCallback showLoading;
  final VoidCallback toggleIsFirstTimeLogin;
  const SignUpForm(
      {required this.showLoading, required this.toggleIsFirstTimeLogin});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final AuthService _authService = AuthService();
  final formKey = GlobalKey<FormState>();

  String username = "";
  String email = "";
  String password = "";

  signUpUser() async {
    final isValid = formKey.currentState?.validate();

    if (isValid!) {
      formKey.currentState!.save();
      widget.toggleIsFirstTimeLogin(); // first time login is true
      widget.showLoading();
      dynamic result = await _authService.register(email, password, username);
      widget.showLoading();
      //TODO: Save username into user data

      if (result == null) {
        final snackBar = SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Sign up failed",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Color(0xFFD74714),
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 80,
              left: 50,
              right: 50),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        // set first time login to false
        widget.toggleIsFirstTimeLogin();
      } else {
        // close sign up modal bottom sheet
        Navigator.of(context).pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        margin: const EdgeInsets.fromLTRB(47, 3, 47, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======== USERNAME ========
            Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 0, 6),
                child: const Text(
                  'Username',
                  style: TextStyle(
                    color: Color(0xfff28705),
                    fontWeight: FontWeight.w600,
                  ),
                )),
            TextFormField(
              maxLength: 16,
              decoration: const InputDecoration(
                errorMaxLines: 3,
                prefixIcon: Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 10, 0),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 21,
                  ),
                ),
                counterText: "",
              ),
              validator: (value) {
                const pattern =
                    r"^(?=[a-zA-Z0-9._]{4,20}$)(?!.*[_.]{2})[^_.].*[^_.]$";
                final regEx = RegExp(pattern);

                if (value!.length < 4 || value.length > 20) {
                  return 'Must be within 4 to 20 alphanumeric characters, underscores, or periods';
                } else if (!regEx.hasMatch(value)) {
                  return 'Must not have leading, trailing, and repeating underscores and periods';
                } else {
                  return null;
                }
              },
              onSaved: (value) => username = value!,
            ),

            // ======== EMAIL ========
            Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 0, 6),
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
                  return 'Must be a valid email';
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
                validator: (value) {
                  const pattern =
                      r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{7,}$";
                  final regEx = RegExp(pattern);

                  if (value!.length < 7) {
                    return 'Must be at least 7 characters long';
                  } else if (!regEx.hasMatch(value)) {
                    return 'Must have one uppercase, lowercase, number, and special character';
                  } else {
                    return null;
                  }
                },
                onChanged: (value) => password = value),

            // ======== CONFIRM PASSWORD ========
            Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 0, 6),
                child: const Text(
                  'Confirm Password',
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
                validator: (value) {
                  if (value != password) {
                    return 'Passwords don\'t match';
                  } else {
                    return null;
                  }
                },
                onSaved: (value) => password = value!),

            SizedBox(height: 30),
            // ======== ENTER BUTTON ========
            ElevatedButton(onPressed: signUpUser, child: const Text('Enter')),
          ],
        ),
      ),
    );
  }
}
