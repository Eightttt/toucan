import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final VoidCallback showLogInSheet;
  const SignUp(this.showLogInSheet, {super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

// TODO: add Navigator.of(context).pop(context) after signing up
class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children:  [
        // ======== TITLE ========
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.fromLTRB(0, 63, 0, 63),
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
            decoration: const InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 10, 0),
                child: Icon(Icons.person_outline_rounded, size: 21,),
              ),
            ),
            validator: (value) {
              if (value != null) {
                return 'Field is empty';
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
              prefixIcon: Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 10, 0),
                child: Icon(Icons.email_outlined, size: 21,),
              ),
            ),
            validator: (value) {
              if (value != null) {
                return 'Field is empty';
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
              prefixIcon: Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 10, 0),
                child: Icon(Icons.lock_outline_rounded, size: 21,),
              ),
            ),
            validator: (value) {
              if (value != null) {
                return 'Field is empty';
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
              onPressed: () {
                Navigator.of(context).pop(context);
              },
              child: const Text('Enter')
          ),
        ),

        // ======== ALREADY HAVE AN ACCOUNT ========
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.fromLTRB(47, 3, 47, 150),
          child: TextButton(
              onPressed: () async {
                Navigator.of(context).pop(context);
                await Future.delayed(const Duration(milliseconds: 200), () => widget.showLogInSheet()
                );
              },
              child: const Text('Already have an account?')
          ),
        )
      ],
    );
  }
}
