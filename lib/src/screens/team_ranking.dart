import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/detail/team_detail.dart';
import 'package:esi_tfg_app/src/services/storage_service.dart';
import 'package:esi_tfg_app/src/widgets/app_card.dart';
import 'package:esi_tfg_app/src/widgets/app_texfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class TeamRanking extends StatefulWidget {
  static const String routeName = '/ranking';

  const TeamRanking({Key? key}) : super(key: key);

  @override
  State<TeamRanking> createState() => _TeamRankingState();
}

class _TeamRankingState extends State<TeamRanking> {
  late User loggedInUser;
  QuerySnapshot<Map<String, dynamic>>? _teams;
  QuerySnapshot<Map<String, dynamic>>? _users;
  QuerySnapshot<Map<String, dynamic>>? _degrees;
  QuerySnapshot<Map<String, dynamic>>? _challenges;
  String _team = "";
  bool _showSpinner = false; 
  late TextEditingController _teamController;
  final Storage storage = Storage();

  @override
  void initState() {
    super.initState();
    
    _teamController = TextEditingController();
    _getRightUser();
  }

    @override
  void dispose(){
    super.dispose();
    _teamController.dispose();
  }

  void _getRightUser() async {
    try{
    var user = await Authentication().getRightUser();
    _teams = await FirestoreService().getMessage(collectionName: "teams");
    _users = await FirestoreService().getMessage(collectionName: "users");
    _degrees = await FirestoreService().getMessage(collectionName: "degrees");
    _challenges = await FirestoreService().getMessage(collectionName: "challenges");

    if (user != null){
      if (mounted){
        setState(() {
          loggedInUser = user;
        });
      }

    }
    }catch(e){
      Fluttertoast.showToast(
        msg: e.toString(),
        fontSize: 20,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[400]
      );
    }
  }

  final TextStyle _sendButtonStyle = const TextStyle(
    color: Colors.white,
    fontSize: 18.0
  );

  void setSpinnersStatus(bool status){
    setState(() {
      _showSpinner = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20.0,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: _teamField()
                  ),
                  Padding(
                    padding:  const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onPrimary, 
                        backgroundColor: const Color.fromARGB(255, 180, 50, 87),
                      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                      onPressed: (){
                        var aux = _teamController.text;
                        _teamController.clear;
                        if (mounted){
                          setState(() {
                            _team = aux;
                          });
                        }
                      },
                      child: Text("Buscar", style: _sendButtonStyle,)
                    ),
                  ),
                ],
              ),
              _teams!= null ? _getTeams(_team) : const Text("Cargando..."),
            ],
          ),
        ),
      )
    );
  }

  Widget _teamField(){
    return AppTextField(
      error: "",
      icon: const Icon(Icons.search),
      controller: _teamController,
      hint: "Equipo",
      label: "Buscar equipo",
      obscureText: false
    ); 
  }

  Widget _getTeams(String teamsSearched){
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirestoreService().getMessage(collectionName: "teams"),
      builder: (context, snapshot){
        return snapshot.connectionState == ConnectionState.waiting ? 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,    
            children:<Widget>[
              Container(
                padding: const EdgeInsets.only(top: 100.0),
                child: Center( 
                  child: Platform.isAndroid ? 
                  const CircularProgressIndicator() 
                  : const CupertinoActivityIndicator()
                )
              )
            ]
          )        
          : snapshot.hasData ? Flexible(
            child: ListView.builder(
              addRepaintBoundaries: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) =>
                _getItems(context, snapshot.data!.docs[index], teamsSearched),
            )
          )
        : Container(height: 0.0,);
      },
    );
  }

  Widget _getAppCard(Widget? icon, QueryDocumentSnapshot<Map<String, dynamic>> team){
    String number = team['name'].toString();
    String degree = team['degree'];
    Color background = Colors.white;
    int teamExp=0;
    double expMedia;

    QueryDocumentSnapshot<Map<String, dynamic>>? docDegree = 
      _degrees!.docs.firstWhere((element) => element['titulo'] == degree);
    Color decoration = Color.fromARGB(docDegree['color'][0], docDegree['color'][1], docDegree['color'][2], docDegree['color'][3]);

    DocumentReference refProfesor = team['teacher'];
    QueryDocumentSnapshot<Map<String, dynamic>>? teacherDoc = 
      _users!.docs.firstWhere((element) => element.reference == refProfesor);
    teamExp += _addChallenges(teacherDoc['challenges_completed']);

    if(team['mentor']!= null){
      DocumentReference refMentor = team['mentor'];
      QueryDocumentSnapshot<Map<String, dynamic>>? mentorDoc = 
        _users!.docs.firstWhere((element) => element.reference == refMentor);
      teamExp += _addChallenges(mentorDoc['challenges_completed']);
    }

    Map<String, dynamic> studentsMap = team['students'];
    if(studentsMap.isNotEmpty){
      Iterable<dynamic> students = studentsMap.values;
      for(var student in students){
        var selectedStudent = _users!.docs.firstWhere((element) => element.reference == student);
        teamExp += _addChallenges(selectedStudent['challenges_completed']);
      }
    }
    if(team['mentor']!= null){
      expMedia = teamExp / (studentsMap.length+2);
    }else{
      expMedia = teamExp / (studentsMap.length+1);
    }
    
    
    return AppCard(
      active: false,
      color: background,
      radius: 3.0,
      borderColor: decoration,
      iconColor: decoration,
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
      subtitle: Text('Experiencia media: $expMedia px\nGrado: $degree', style: const TextStyle(fontSize: 15.0)),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => TeamDetail(team: team, loggedInUser: loggedInUser,)));
      }
    );
  }

  int _addChallenges(Map<String, dynamic> challengesDoneMap){
    int totalExp=0;
    Iterable<dynamic> challenges = challengesDoneMap.values;
    for(var challenge in challenges){
      var selectedChallenge = _challenges!.docs.firstWhere((element) => element.reference == challenge);
      switch(selectedChallenge["level"]){
        case 1:
          totalExp +=1;
          break;
        case 5:
          totalExp +=5;
          break;
        case 20:
          totalExp +=20;
          break;
      }
    }
    return totalExp;
  }

  Widget _getItems(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> team, String teamSearched){
    String conjunto = "Equipo ${team['name'].toString()}";
    if(teamSearched == ""){
      return _getAppCard(const Icon(Icons.groups_rounded),team);
    }else{
      if(conjunto.contains(teamSearched)){
        return _getAppCard(const Icon(Icons.groups_rounded),team);
      }else{
        return Container(height: 0.0,);
      }
    }
  }
}