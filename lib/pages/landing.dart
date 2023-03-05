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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Image.asset('assets/toucan-title-logo.png', height: 102,),
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
        Image.asset('assets/preview.png', height: 281,),
        const Text(
          'Stay on top of your goals \nwith Toucan',
          style: TextStyle(
              fontWeight: FontWeight.bold,
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
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFFFDFDF5)),
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered)) {
                    return const Color(0xD7D07205);
                  }
                  if (states.contains(MaterialState.focused) ||
                      states.contains(MaterialState.pressed)) {
                    return const Color(0xD7D07205);
                  }
                  return null; // Defer to the widget's default.
                },
              ),
            ),
          child: const Text(
            'Sign Up',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFDFDF5),
            ),
          )
        ),
        TextButton(
          onPressed: () {}, // TODO: Route to Log-in page
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(const Color(0xD72D2D2D)),
          ),
          child: const Text('Log-in'),
        )
      ],
    );
  }
}
