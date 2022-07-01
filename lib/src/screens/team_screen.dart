import 'package:flutter/material.dart';

class Team extends StatefulWidget {
  static const String routeName = '/equipo';
  const Team({Key? key}) : super(key: key);

  @override
  State<Team> createState() => _TeamState();
}

class _TeamState extends State<Team>{
 
  @override
  Widget build(BuildContext context) {
    return _teamWidget();
  }

  Widget _teamWidget(){
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