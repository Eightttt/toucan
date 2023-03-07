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
  final formKey = GlobalKey<FormState>();

  logInUser() {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: ListView(
          children:  [
            // ======== EMAIL ========
            Container(
                margin: EdgeInsets.fromLTRB(
                    57, MediaQuery.of(context).size.height * 0.05,
                    0, 3),
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
                    return 'Invalid email';
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
                  errorMaxLines: 3,
                  prefixIcon: Padding(
                    padding: EdgeInsets.fromLTRB(12, 0, 10, 0),
                    child: Icon(Icons.lock_outline_rounded, size: 21,),
                  ),
                ),
                validator: (value) {
                  const pattern = r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{7,}$";
                  final regEx = RegExp(pattern);

                  if (!regEx.hasMatch(value!)) {
                    return 'Incorrect Password';
                  } else {
                    return null;
                  }
                },
              ),
            ),

            // ======== FORGOT PASSWORD ========
            Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.fromLTRB(57, 5, 0, 0),
              child: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
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
              margin: EdgeInsets.fromLTRB(
                  47, MediaQuery.of(context).size.height * 0.045,
                  47, MediaQuery.of(context).size.height * 0.045),
              child: ElevatedButton(
                  onPressed: logInUser,
                  child: const Text('Enter')
              ),
            ),
          ],
        ),
      ),
    );
  }
}