import "package:flutter/material.dart";
import 'package:toucan/services/auth.dart';

class Confirmation extends StatelessWidget {
  const Confirmation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerRight,
          child: Image.asset(
            'assets/toucan-title-logo.png',
            width: 140,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding:EdgeInsets.all(30),
          child: Column(
            children: [
              SizedBox(height: 100),
              Text(
                'Thank you for registering!',
                style: TextStyle(
                  color: Color(0xfff28705),
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              Image.asset('assets/toucan-confirmation-temp.PNG'),
              SizedBox(height: 20),
              Text(
                'We look forward to being your \n'
                'goal partner',
                style: TextStyle(
                  color: Color(0xfff28705),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 150),
              ElevatedButton(
                  onPressed: () {},
                  child: Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
