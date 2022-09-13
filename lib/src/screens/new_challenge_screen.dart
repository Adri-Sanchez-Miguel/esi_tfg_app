import 'package:flutter/material.dart';

class NuevoReto extends StatelessWidget {
  static const String routeName = "/newchallenge"; 
  const NuevoReto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo reto"),
      ),
      body: const Center(
        child: Text("Nuevo reto")
        ),
    );
  }
}