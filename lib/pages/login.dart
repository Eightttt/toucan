import 'package:flutter/material.dart';

class LogIn extends StatefulWidget {
  const LogIn({
    super.key,
  });

  @override
  State<LogIn> createState() => _LogInState();
}

// TODO: add Navigator.of(context).pop(context) after logging in
class _LogInState extends State<LogIn> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:  [
        // ======== EMAIL ========
        Container(
            margin: const EdgeInsets.fromLTRB(57, 37, 0, 3),
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
          margin: const EdgeInsets.fromLTRB(47, 3, 47, 0),
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

        // ======== FORGOT PASSWORD ========
        Container(
          margin: const EdgeInsets.fromLTRB(47, 0, 47, 0),
          child: TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 12,
              )
            ),
              onPressed: () async {
                // TODO: Add forgot password feature
                Navigator.of(context).pop(context);
              },
              child: const Text('Forgot Password?')
          ),
        ),

        // ======== ENTER BUTTON ========
        Container(
          margin: const EdgeInsets.fromLTRB(47, 28, 47, 100),
          child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(context);
              },
              child: const Text('Enter')
          ),
        ),
      ],
    );
  }
}