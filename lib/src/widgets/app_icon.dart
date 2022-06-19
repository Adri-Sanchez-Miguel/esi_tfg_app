import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
          Center(child: Image.asset('images/menthor_logo.png', width: 325.0,)),
      ],
    );
  }
}