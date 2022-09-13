import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:flutter/material.dart';

class TeamDetail extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? team;
  const TeamDetail({Key? key, required this.team}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = team!['name'].toString();
    DocumentReference? mentor;

    if(team!['mentor'] != null){
      mentor = team!['mentor'];
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Team"),
        ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
        child: _getList("users", name, mentor),
      ),
    );
  }

  Widget _getList(String collectionName, String name, DocumentReference? mentor){
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirestoreService().getMessage(collectionName: collectionName),
      builder: (context, snapshot){
        if(snapshot.hasData){
          var messages = snapshot.data!.docs;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(child: Text("Equipo $name", 
                style: const TextStyle(color: Color.fromARGB(255, 180, 50, 87), fontSize: 35.0, fontWeight: FontWeight.bold),),),
              const SizedBox(height: 30.0,), 
              const Text("Profesor/a:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
              _getTeacherItem(messages, team!["teacher"]),
              const SizedBox(height: 30.0,), 
              const Text("Mentor:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
              team!['mentor'] != null ? _getMentorItem(messages, mentor) : const Text("Aún no hay mentor"),
              const SizedBox(height: 40.0,),
              const Text("Mentorizazdos:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
              Flexible(
                child: ListView(
                  children: _getStudentItems(messages),
                )
              )
            ]
          );

        }else{
          return const Text("No hay alumnos en este equipo");
        }
      },
    );
  }

  Widget _getTeacherItem(List<QueryDocumentSnapshot<Map<String, dynamic>>> messages, DocumentReference? teacher) {
    var selectedTeacher = messages.firstWhere((element) => element.reference == teacher);
    return Text(selectedTeacher['email'], style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),);
  }

  Widget _getMentorItem(List<QueryDocumentSnapshot<Map<String, dynamic>>> messages, DocumentReference? mentor) {
    var selectedMentor = messages.firstWhere((element) => element.reference == mentor);
    return Text(selectedMentor['email'], style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),);
  }

  List<Widget> _getStudentItems(dynamic messages){
    List<Widget> messageItems = [];
    Map<String, dynamic> studentsMap = team!['students'];
    Iterable<dynamic> students = studentsMap.values;
    for(var student in students){
      var selectedStudent = messages.firstWhere((element) => element.reference == student);
      messageItems.add(Text(selectedStudent['email'], style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),));
    }
    return messageItems;
  }
}