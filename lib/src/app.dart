import 'package:esi_tfg_app/src/screens/login_screen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Iniciar Sesión",
      home: Scaffold(
        body: LoginScreen(),
      ),
    );
  }
}