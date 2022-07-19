import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/detail/team_detail.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:esi_tfg_app/src/widgets/app_card.dart';
import 'package:flutter/material.dart';

class Team extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  const Team({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Equipo"),
          backgroundColor: const Color.fromARGB(255, 180, 50, 87),
        ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _getTeams(context),
          ]
        )
      ),
    );
  }
  Widget _getTeams(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirestoreService().getMessage(collectionName: "teams"),
      builder: (context, snapshot){
        if(snapshot.hasData){
          List<QueryDocumentSnapshot<Map<String, dynamic>>> messages = snapshot.data!.docs;
          return Flexible(
            child: ListView(
              children: _getTeamsItems(context, messages),
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

  List<Widget> _getTeamsItems(BuildContext context, List<QueryDocumentSnapshot<Map<String, dynamic>>> messages){
    List<Widget> messageItems = [];
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> teams = messages.where((element) => element['teacher'] == user!.reference);
    for(var team in teams){
      messageItems.add(_getAppCard(const Icon(Icons.work), team, context));
    }
    return messageItems;
  }

  Widget _getAppCard(Widget? icon, QueryDocumentSnapshot<Map<String, dynamic>> team, BuildContext context){
    String number = team['name'].toString();
    Color background = Colors.white;
    String degree = team['degree'];

    return AppCard(
      color: background,
      radius: 3.0,
      borderColor: Colors.black,
      iconColor: Colors.black,
      textColor: Colors.black,
      leading: icon,
      title: Text.rich(
        TextSpan(
          text: '', 
          children: <TextSpan>[
            TextSpan(text: 'Equipo $number\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ],
        ),
      ),
      subtitle: Text('Grado: $degree', style: const TextStyle(fontSize: 15.0)),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => TeamDetail(team: team)));
      }
    );
  }
}