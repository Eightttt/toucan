import 'package:flutter/material.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              fontWeight: FontWeight.w900,
              fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class Buttons extends StatelessWidget {
  const Buttons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: (){}, // TODO: Route to Signup page
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 8,
              minimumSize: const Size(160, 40),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
              foregroundColor: const Color(0xFFFDFDF5),

            ),
          child: const Text('Sign Up')
        ),
        TextButton(
          onPressed: () {}, // TODO: Route to Log-in page
          style: TextButton.styleFrom(
              foregroundColor: const Color(0xD72D2D2D),
            textStyle: const TextStyle(fontSize: 11)
          ),
          child: const Text('Log-in'),
        )
      ],
    );
  }
}
