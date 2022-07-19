import 'package:flutter/material.dart';

class NuevoMensaje extends StatelessWidget {
  static const String routeName = "/newchallenge"; 
  const NuevoMensaje({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo reto"),
        backgroundColor: const Color.fromARGB(255, 180, 50, 87),
      ),
      body: const Center(
        child: Text("Nuevo reto")
        ),
    );
  }
}