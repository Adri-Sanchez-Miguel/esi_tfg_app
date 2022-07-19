import 'package:flutter/material.dart';

class ReclamarLogro extends StatelessWidget {
  static const String routeName = "/achieve"; 
  const ReclamarLogro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reclamar logro"),
      ),
      body: const Center(
        child: Text("Reclamar logro")
        ),
    );
  }
}