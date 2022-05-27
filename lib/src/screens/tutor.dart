import 'package:flutter/material.dart';

class Tutor extends StatelessWidget {
  static const String routeName = "/tutor"; 
  const Tutor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutor"),
      ),
      body: const Center(
        child: Text("Tutor")
        ),
    );
  }
}