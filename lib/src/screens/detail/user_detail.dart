import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:flutter/material.dart';

class UserDetail extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  const UserDetail({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("User"),
          backgroundColor: const Color.fromARGB(255, 180, 50, 87),
        ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(child: Text(user!['email'])),
            _getList("teams", true),
            _getList("challenges", false)
          ]
        )
      ),
    );
  }

  Widget _getList(String collectionName, bool decider){
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirestoreService().getMessage(collectionName: collectionName),
      builder: (context, snapshot){
        if(snapshot.hasData){
          var messages = snapshot.data!.docs;
          return Flexible(
            child: ListView(
              children: decider ? _getTeacherItems(messages) : _getChallengeItems(messages),
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

  List<Widget> _getTeacherItems(dynamic messages){
    List<Widget> messageItems = [];
    Map<String, dynamic> teamsMap = user!['team'];
    Iterable<dynamic> teams = teamsMap.values;
    for(var team in teams){
      var selectedTeam = messages.firstWhere((element) => element.reference == team);
      var name = selectedTeam['name'].toString();
      messageItems.add(Text("Equipo $name"));
    }
    return messageItems;
  }

  List<Widget> _getChallengeItems(dynamic messages){
    List<Widget> messageItems = [];
    Map<String, dynamic> challengesMap = user!['challenges_completed'];
    Iterable<dynamic> challenges = challengesMap.values;
    for(var challenge in challenges){
      var selectedChallenge = messages.firstWhere((element) => element.reference == challenge);
      var name = selectedChallenge['name'];
      messageItems.add(Text("Reto: $name"));
    }
    return messageItems;
  }
}