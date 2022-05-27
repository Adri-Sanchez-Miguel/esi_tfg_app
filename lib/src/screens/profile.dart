import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  static const String routeName = "/perfil"; 
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
      ),
      body: const Center(
        child: Text("Perfil")
        ),
    );
  }
}