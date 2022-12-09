import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/home.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:esi_tfg_app/src/widgets/app_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SelectTeam extends StatefulWidget {
  static const String routeName = '/selectteam';
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  const SelectTeam({Key? key, this.user}) : super(key: key);

  @override
  State<SelectTeam> createState() => _SelectTeamState();
}

class _SelectTeamState extends State<SelectTeam> {
  bool _showSpinner = false;
  bool _completed = false; 
  bool rechargePage = false;
  QueryDocumentSnapshot? _team;
  QuerySnapshot<Map<String, dynamic>>? _snap;
  QuerySnapshot<Map<String, dynamic>>? _degrees;
  List<Map> _data = List.generate(1000,(index) => {'isSelected': false});
  
  @override
  void initState() {
    super.initState();
    _getEmail();
  }

  void setSpinnersStatus(bool status){
    setState(() {
      _showSpinner = status;
    });
  }

  void _getEmail() async {
    try{
      _snap = await FirestoreService().getMessage(collectionName: "users");
      _degrees = await FirestoreService().getMessage(collectionName: "degrees");
      setState(() {
        if(_snap !=null && _degrees != null){
          rechargePage = true;
        }
      });
    }catch(e){
      Fluttertoast.showToast(
        msg: e.toString(),
        fontSize: 20,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[400]
      );
    }
  }

  String _getFinalRole(){ 
  if(widget.user!['email'].endsWith('@uclm.es')){
        return "profesor";
    }
    else{
      if(widget.user!['role'] == "mentorizado"){
        return "mentorizado";
      }else{
        return "mentor";
      }
    }
  }

  @override
  Widget build(BuildContext context){
    setSpinnersStatus(false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Equipo"),
      ),
      body: rechargePage ? ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child:Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,    
            children:  _getFinalRole() == "profesor" ? _widgetTeacher() : _widgetStudent()
          ),
        ),
      ) : Row(
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
        ),
    );
  }

  List<Widget> _widgetTeacher(){
    return <Widget>[
      const SizedBox(height: 10.0,), 
      const Text("¡Hola profesor/a!", style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.w900, color: Color.fromARGB(255, 180, 50, 87)),),
      const SizedBox(height: 20.0,),
      const Center(child: Text("Tendrás uno o varios equipos de los que hacerte cargo, con la posibilidad de crear y conseguir retos. ¡Gracias por unirte al proyecto!.", style: TextStyle(fontSize: 15.0),),),
      const SizedBox(height: 20.0,),
      Image.asset('images/menthor_logo.png'),
      const SizedBox(height: 50.0,),
      _getBack()
    ];
  }

  List<Widget> _widgetStudent(){
    return <Widget>[
      const SizedBox(height: 5.0,), 
      const Center(child:Text("Elige tu equipo", style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w700, color: Color.fromARGB(255, 180, 50, 87)),),),
      const SizedBox(height: 20.0,),
      _getListViewTeams(),
      const SizedBox(height: 20.0,),   
      const Center(child: Text("Tip: Si no aparece ningún equipo, significa que están completos. Envíe un mensaje a menthor.uclm@gmail.com para que le de solución al problema.", 
        style: TextStyle(fontSize: 16.0),
      )),
      const SizedBox(height: 10.0,),
      _getBack()
    ];
  }

  Widget _getListViewTeams() {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirestoreService().getMessage(collectionName: "teams"),
      builder: (context, snapshot){
        try{
          if(snapshot.hasData){
            return Flexible(
              child: ListView.builder(
                addRepaintBoundaries: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) =>
                  _getListTileTeams(context, snapshot.data!.docs[index], _data[index]['isSelected'], index),
              ),
            );
          }else{
            return Container(
              height: 0.0,
            );
          }
        }catch(e){
          Fluttertoast.showToast(
            msg: e.toString(),
            fontSize: 20,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red[400]
          );
          return Container (height: 0.0,);
        }
      }
    );
  }

  Widget _getListTileTeams(BuildContext context, QueryDocumentSnapshot document, bool active, int index){
    String docDegree = document['degree'];
    QueryDocumentSnapshot<Map<String, dynamic>>? degree = 
      _degrees!.docs.firstWhere((element) => element['titulo'] == docDegree);
    
    if(document['mentor'] != null && _getFinalRole() == "mentor"){
      return Container(height: 0.0,);
    }
    if(document['students'].length >= degree['size_group'] && _getFinalRole() == "mentorizado"){
      return Container(height: 0.0,);
    }
    String docName = document['name'].toString();

    DocumentReference ref = document['teacher'];
    QueryDocumentSnapshot<Map<String, dynamic>>? teacherDoc = 
      _snap!.docs.firstWhere((element) => element.reference == ref);

    Color color = Color.fromARGB(degree['color'][0], degree['color'][1], degree['color'][2], degree['color'][3]);
    
    String teacherName = teacherDoc['email'];
    String subtitle = "$teacherName \nGrado: $docDegree";
    return _createCard(document, docName, subtitle, color, active, index);
  }

  Widget _createCard(QueryDocumentSnapshot document, String docName,  String teacherName, Color color, bool active, int index){
    return AppCard(
      active: active,
      borderColor: color,
      iconColor: color,
      radius: 3.0,
      leading: const Icon(Icons.work),
      title: Text("Equipo $docName",
        style: const TextStyle(fontSize: 20.0)
      ),
      subtitle: Text("Tutor: $teacherName "),
      onTap: (){
        setState(() {
          _data = List.generate(1000,(index) => {'isSelected': false});
          _data[index]['isSelected'] = true;
          _completed = true;
          _team = document;
        });
      }
    );
  }

  void _createTeam() async{
    var snap = await FirestoreService().getMessage(collectionName: "teams");
    if(_getFinalRole() != "profesor"){
      var finalTeam = snap.docs.firstWhere((element) => element.reference == _team!.reference);
      if(_getFinalRole() != "mentor"){
        Map<String, dynamic> students = finalTeam['students'];
        students.addAll({
            (finalTeam['students'].length + 1).toString() : widget.user!.reference,
          });
        await FirestoreService().update(document: finalTeam.reference, collectionValues: {
          'students': students,
        }); 
      }else{
        await FirestoreService().update(document: finalTeam.reference, collectionValues: {
          'mentor': widget.user!.reference,
        }); 
      }
      Map<String, dynamic> teams = widget.user!['team'];
      teams.addAll({
            (widget.user!['team'].length + 1).toString() : finalTeam.reference
        });
      await FirestoreService().update(document: widget.user!.reference, collectionValues: {
        'team': teams,
      }); 
    }else{
      await FirestoreService().save(collectionName: "teams", collectionValues: {
        'teacher': widget.user!.reference,
        'degree': widget.user!['degree'],
        'name': snap.docs.length + 1,
        'students': {},
        'mentor': null
      }); 
      snap = await FirestoreService().getMessage(collectionName: "teams");
      var teacherTeam = snap.docs.firstWhere((element) => element['name'] == snap.docs.length); 
      Map<String, dynamic> teams = widget.user!['team'];
      teams.addAll({
            (widget.user!['team'].length + 1).toString() : teacherTeam.reference
        });
      await FirestoreService().update(document: widget.user!.reference, collectionValues: {
        'team': teams,
      }); 
    }
  }

  Widget _getBack(){
    if(_completed || _getFinalRole() == "profesor"){
      return AppButton(
        color: const Color.fromRGBO(179, 0, 51, 1.0),
        colorText: Colors.white,
        name: "Confirmar",
        onPressed:()async{
          _createTeam();
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
        }
      );
    }else{
      return AppButton(
        color:Colors.black54,
        colorText: Colors.white54,
        name: "Elija un equipo",
        onPressed:()async{}
      );
    }
  }
}