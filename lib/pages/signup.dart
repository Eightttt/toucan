import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final VoidCallback showLogInSheet;
  const SignUp(this.showLogInSheet, {super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();

  signUpUser() {
    final isValid = formKey.currentState?.validate();

    if (isValid!) {
      // TODO: save data
      const snackBar = SnackBar(
        content: Text("Submitted"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      );
      Navigator.of(context).pop(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          // ======== TITLE ========
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.fromLTRB(0, 63, 0, 48),
            child: const Text(
              'Set-up you Account',
              style: TextStyle(
              color: Color(0xfff28705),
                fontWeight: FontWeight.w700,
                fontSize: 25,
              ),
            )
          ),

          // ======== USERNAME ========
          Container(
            margin: const EdgeInsets.fromLTRB(57, 0, 0, 3),
            child: const Text(
              'Username',
              style: TextStyle(
                color: Color(0xfff28705),
                fontWeight: FontWeight.w600,
              ),
            )
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(47, 3, 47, 0),
            child: TextFormField(
              maxLength: 16,
              decoration: const InputDecoration(
                errorMaxLines: 3,
                prefixIcon: Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 10, 0),
                  child: Icon(Icons.person_outline_rounded, size: 21,),
                ),
                counterText: "",
              ),
              validator: (value) {
                const pattern = r"^(?=[a-zA-Z0-9._]{4,20}$)(?!.*[_.]{2})[^_.].*[^_.]$";
                final regEx = RegExp(pattern);

                if (value!.length < 4 || value.length > 20) {
                  return 'Must be within 4 to 20 alphanumeric characters, underscores, or periods';
                } else if (!regEx.hasMatch(value)) {
                  return 'Must not have leading, trailing, and repeating underscores and periods';
                } else {
                  return null;
                }
              },
            ),
          ),

          // ======== EMAIL ========
          Container(
              margin: const EdgeInsets.fromLTRB(57, 10, 0, 3),
              child: const Text(
                'E-mail',
                style: TextStyle(
                  color: Color(0xfff28705),
                  fontWeight: FontWeight.w600,
                ),
              )
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(47, 3, 47, 0),
            child: TextFormField(
              decoration: const InputDecoration(
                errorMaxLines: 3,
                prefixIcon: Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 10, 0),
                  child: Icon(Icons.email_outlined, size: 21,),
                ),
              ),
              validator: (value) {
                const pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                final regEx = RegExp(pattern);
                if (!regEx.hasMatch(value!)) {
                  return 'Must be a valid email';
                } else {
                  return null;
                }
              },
            ),
          ),

          // ======== PASSWORD ========
          Container(
              margin: const EdgeInsets.fromLTRB(57, 10, 0, 3),
              child: const Text(
                'Password',
                style: TextStyle(
                  color: Color(0xfff28705),
                  fontWeight: FontWeight.w600,
                ),
              )
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(47, 3, 47, 34),
            child: TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                errorMaxLines: 3,
                prefixIcon: Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 10, 0),
                  child: Icon(Icons.lock_outline_rounded, size: 21,),
                ),
              ),
              validator: (value) {
                const pattern = r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-])$";
                final regEx = RegExp(pattern);

                if (value!.length < 7) {
                  return 'Must be at least 7 characters long';
                } else if (!regEx.hasMatch(value)) {
                  return 'Must have at least an uppercase, a lowercase, a number, and a special character';
                } else {
                  return null;
                }
              },
            ),
          ),

          // ======== ENTER BUTTON ========
          Container(
            margin: const EdgeInsets.fromLTRB(47, 3, 47, 50),
            child: ElevatedButton(
                onPressed: signUpUser,
                child: const Text('Enter')
            ),
          ),

          // ======== ALREADY HAVE AN ACCOUNT ========
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.fromLTRB(47, 3, 47, 100),
            child: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(context);
                  await Future.delayed(const Duration(milliseconds: 200), widget.showLogInSheet
                  );
                },
                child: const Text('Already have an account?')
            ),
          )
        ],
      ),
    );
  }
}
