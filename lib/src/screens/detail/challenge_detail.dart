import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChallengeDetail extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> challenge;
  const ChallengeDetail({Key? key, required this.challenge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reto")),
      body: GridView.count(
        primary: false,
        crossAxisCount: 1,
        mainAxisSpacing: 3.0,
        crossAxisSpacing: 3.0,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(child:Text(challenge['name'], style: const TextStyle(color: Color.fromARGB(255, 180, 50, 87), fontSize: 30.0, fontWeight: FontWeight.w700))),
                const SizedBox(height: 15.0,), 
                Text(challenge['explanation'], style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),),
                const Divider(thickness: 3.0, height: 30.0, color: Color.fromARGB(255, 180, 50, 87),),
                const Text("Disponible hasta:", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w700),),
                Text(challenge['end_date'].toDate().toString(), style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),),
                const SizedBox(height: 15.0,),
                const Text("Nivel:", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w700),),
                _getLevel(challenge['level']),
                const SizedBox(height: 20.0, 
                child: Divider(thickness: 3.0, color: Color.fromARGB(255, 180, 50, 87),),),
              ]
            )
          ),
        ]
      )
    );
  }
  
  Widget _getLevel(int level) {
    switch(level){
      case 1:
        return const Text("Bronce", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500));
      case 2:
        return const Text("Plata", style:  TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500));
      case 3:
        return const Text("Oro", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500));
      default:
        return const Text("Error", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500));
    }
  }
}