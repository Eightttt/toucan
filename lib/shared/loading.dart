import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  final double size;
  Loading({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: SpinKitFoldingCube(
          duration: Duration(milliseconds: 1250),
          color: Color(0xfff28705),
          size: size,
        ),
      ),
    );
  }
}
