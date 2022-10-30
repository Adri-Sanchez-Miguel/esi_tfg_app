import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/detail/user_detail.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TeamDetail extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? team;
  const TeamDetail({Key? key, required this.team}) : super(key: key);

@override
  State<TeamDetail> createState() => _TeamDetailState();
}

class _TeamDetailState extends State<TeamDetail> {
  int _gold =0, _silver =0, _bronze=0;
  bool decider = false;
  QuerySnapshot<Map<String, dynamic>>? _allChallenges;

  @override
  void initState() {
    super.initState();
    _getChallenges();
  }

  void _getChallenges() async {
    try{
    _allChallenges = await FirestoreService().getMessage(collectionName: "challenges");
    if(_allChallenges!= null){setState(() {
      decider = true;
    });}
    }catch(e){
      Fluttertoast.showToast(
        msg: e.toString(),
        fontSize: 20,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[400]
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.team!['name'].toString();
    DocumentReference? mentor;

    if(widget.team!['mentor'] != null){
      mentor = widget.team!['mentor'];
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Team"),
        ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
        child: _getList(context, "users", name, mentor),
      ),
    );
  }

  Widget _getList(BuildContext context, String collectionName, String name, DocumentReference? mentor){
    if(decider){
      return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirestoreService().getMessage(collectionName: collectionName),
        builder: (context, snapshot){
          if(snapshot.hasData){
            Map<String, dynamic> studentsMap = widget.team!['students'];
            var messages = snapshot.data!.docs;
            return SingleChildScrollView(
              child:Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(child: Text("Equipo $name", 
                    style: const TextStyle(color: Color.fromARGB(255, 180, 50, 87), fontSize: 35.0, fontWeight: FontWeight.bold),),),
                  const SizedBox(height: 30.0,),
                  const Text("Profesor/a:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
                  _getTeacherItem(context, messages, widget.team!["teacher"]),
                  const SizedBox(height: 10.0,),
                  const Divider(thickness: 1.0, color: Colors.black,),            
                  const SizedBox(height: 10.0,), 
                  const Text("Mentor/a:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
                  widget.team!['mentor'] != null ? _getMentorItem(context, messages, mentor) : const Text("Aún no hay mentor"),
                  const SizedBox(height: 10.0,),
                  const Divider(thickness: 1.0, color: Colors.black,),            
                  const SizedBox(height: 10.0,),
                  const Text("Mentorizazdos:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
                  studentsMap.isNotEmpty ? Flexible(
                    fit: FlexFit.loose,
                    child: SizedBox(
                      height:200.0,
                      child:ListView(
                        children: _getStudentItems(context, messages),
                      )
                    )
                  ):const Text("Aún no hay mentorizados"),
                  const SizedBox(height: 10.0,),
                  const Divider(thickness: 1.0, color: Colors.black,),            
                  const SizedBox(height: 10.0,),
                  const Text("Retos del equipo:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
                  _getChallengeRow()
                ]
              )
            );

          }else{
            return const Text("No hay alumnos en este equipo");
          }
        },
      );
    }else{
      return const Text("Cargando...");
    }
  }

  Widget _getTeacherItem(BuildContext context,List<QueryDocumentSnapshot<Map<String, dynamic>>> messages, DocumentReference? teacher) {
    var selectedTeacher = messages.firstWhere((element) => element.reference == teacher);
    _addChallenges(selectedTeacher['challenges_completed']);
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 209, 73, 111),
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetail(user: selectedTeacher)));
      },
      child: Text(selectedTeacher['email']),
    );
  }

  Widget _getMentorItem(BuildContext context, List<QueryDocumentSnapshot<Map<String, dynamic>>> messages, DocumentReference? mentor) {
    var selectedMentor = messages.firstWhere((element) => element.reference == mentor);
    _addChallenges(selectedMentor['challenges_completed']);
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: const Color.fromARGB(255, 209, 73, 111),
        textStyle: const TextStyle(fontSize: 20),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetail(user: selectedMentor)));
      },
      child: Text(selectedMentor['email']),
    );
  }

  List<Widget> _getStudentItems(BuildContext context, dynamic messages){
    List<Widget> messageItems = [];
    Map<String, dynamic> studentsMap = widget.team!['students'];
    Iterable<dynamic> students = studentsMap.values;
    
    for(var student in students){
      var selectedStudent = messages.firstWhere((element) => element.reference == student);
      _addChallenges(selectedStudent['challenges_completed']);
      messageItems.add(
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 209, 73, 111),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetail(user: selectedStudent)));
          },
          child: Text(selectedStudent['email']),
        )
      );
    }
    return messageItems;
  }

  void _addChallenges(Map<String, dynamic> challengesDoneMap){
    Iterable<dynamic> challenges = challengesDoneMap.values;
    for(var challenge in challenges){
      var selectedChallenge = _allChallenges!.docs.firstWhere((element) => element.reference == challenge);
      switch(selectedChallenge["level"]){
        case 1:
          _bronze +=1;
          break;
        case 5:
          _silver +=1;
          break;
        case 20:
          _gold +=1;
          break;
      }
    }
  }

  Widget _getChallengeRow(){
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset('images/gold.png',height: 50.0),
          Text(_gold.toString(), style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),),
          Image.asset('images/silver.png',height: 50.0),
          Text(_silver.toString(), style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),),
          Image.asset('images/bronze.png',height: 50.0),
          Text(_bronze.toString(), style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),),        
        ]
      )
    );
  }
}