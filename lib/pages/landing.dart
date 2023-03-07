import 'package:flutter/material.dart';
import 'package:toucan/pages/authenticate/signup.dart';
import 'package:toucan/pages/authenticate/login.dart';

class Landing extends StatelessWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Image.asset('assets/toucan-title-logo.png', height: 102),
                  const Preview(),
                  const Buttons(),
                ],
              ),
            ],
          ),
      ),
    );
  }
}

class Preview extends StatelessWidget {
  const Preview({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/preview.png', height: 371,),
        const Text(
          'Stay on top of your goals \nwith Toucan',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class Buttons extends StatefulWidget {
  const Buttons({
    super.key,
  });

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {

  showSignUpSheet() {
    // TODO: Animate other elements
    return showModalBottomSheet<void>(
      isScrollControlled: true,
      enableDrag: false,
      context: context,
      builder: (BuildContext context) {
        return SignUp(showLogInSheet);
      }
    );
  }

  showLogInSheet() {
    // TODO: Animate other elements
    return showModalBottomSheet<void>(
        enableDrag: false,
        context: context,
        builder: (BuildContext context) {
          return const LogIn();
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            showSignUpSheet();
        },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(160, 40),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.5,
              ),
            ),
          child: const Text('Sign Up')
        ),
        TextButton(
            onPressed: () {
              showLogInSheet();
            },
          style: TextButton.styleFrom(
              foregroundColor: const Color(0xD72D2D2D),
              textStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w300,
              )
          ),
          child: const Text('Log-in'),
        ),
      ],
    );
  }
}

