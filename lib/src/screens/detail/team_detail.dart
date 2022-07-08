import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:flutter/material.dart';

class TeamDetail extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? team;
  const TeamDetail({Key? key, required this.team}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = team!['name'].toString();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Team"),
          backgroundColor: const Color.fromARGB(255, 180, 50, 87),
        ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(child: Text("Equipo $name")),
            _getList("users"),
          ]
        )
      ),
    );
  }

  Widget _getList(String collectionName){
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirestoreService().getMessage(collectionName: collectionName),
      builder: (context, snapshot){
        if(snapshot.hasData){
          var messages = snapshot.data!.docs;
          return Flexible(
            child: ListView(
              children: _getStudentItems(messages),
            )
          );
        }else{
          return Container(
            height: 0.0,
          );
        }
      },
    );
  }

  List<Widget> _getStudentItems(dynamic messages){
    List<Widget> messageItems = [];
    Map<String, dynamic> studentsMap = team!['students'];
    Iterable<dynamic> students = studentsMap.values;
    for(var student in students){
      var selectedStudent = messages.firstWhere((element) => element.reference == student);
      var name = selectedStudent['email'];
      messageItems.add(Text("$name"));
    }
    return messageItems;
  }
}