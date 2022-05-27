import 'package:flutter/material.dart';

class Team extends StatelessWidget {
  static const String routeName = "/equipo"; 
  const Team({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Equipo"),
      ),
      body: const Center(
        child: Text("Equipo")
        ),
    );
  }
}