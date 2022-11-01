import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/detail/challenge_detail.dart';
import 'package:esi_tfg_app/src/widgets/app_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ChallengeScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  static const String routeName = '/challenges';

  const ChallengeScreen({Key? key, this.user}) : super(key: key);

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  late User loggedInUser;
  QuerySnapshot<Map<String, dynamic>>? _users;
  bool _showSpinner = false; 

  @override
  void initState() {
    super.initState();
    _getRightUser();
  }

  void _getRightUser() async {
    try{
    var user = await Authentication().getRightUser();
    _users = await FirestoreService().getMessage(collectionName: "users");
    if (user != null){
      setState(() {
        loggedInUser = user;
      });
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

  void setSpinnersStatus(bool status){
    setState(() {
      _showSpinner = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_users!= null){
      return Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                _getChallenges(),
              ],
            ),
          ),
        )
      );
    }else{
      return const Text("Cargando...");
    }
  }

  Widget _getChallenges(){
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirestoreService().getMessage(collectionName: "challenges"),
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
            child: RefreshIndicator(
              onRefresh: () async{
                setState((){
                  _getChallenges();
                });
              },
              child: ListView.builder(
                physics:  const AlwaysScrollableScrollPhysics(),
                addRepaintBoundaries: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) =>
                  _getItems(context, snapshot.data!.docs[index]),
              )
            )
          )
        : Container(height: 0.0,);
      },
    );
  }

  Widget _getAppCard(Widget? icon, QueryDocumentSnapshot<Map<String, dynamic>> challenge, Color? colorDecoration){
    DateTime endDate = challenge['end_date'].toDate();
    Duration duration = endDate.difference(DateTime.now());
    String difference = "";
    Color background = Colors.white;
    String title = challenge['name'];
    String description = challenge['explanation'];

    if(endDate.year == 2039){
      difference = "Fecha límite: Siempre disponible";
    }else{
      int hours = duration.inHours;
      if(hours>23){
        int days = duration.inDays;
        difference = "Fecha límite : $days días";
      }else{
        difference = "Fecha límite : $hours horas";
      }
    }
    return AppCard(
      color: background,
      radius: 3.0,
      borderColor: Colors.black,
      textColor: Colors.black,
      leading: icon,
      title: Text.rich(
        TextSpan(
          text: '', 
          children: <TextSpan>[
            TextSpan(text: '$title\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
            TextSpan(text: difference, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15.0)),
          ],
        ),
      ),
      subtitle: Text('\n$description'),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChallengeDetail(challenge: challenge, user: widget.user)));
      }
    );
  }

  Widget _getItems(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> challenge){
    if(challenge['end_date'].toDate().isAfter(DateTime.now())){
      QueryDocumentSnapshot<Map<String, dynamic>> user = _users!.docs.firstWhere((element) => element["email"] == loggedInUser.email);
      Map<String, dynamic> completed = user['challenges_completed'];
      if(!completed.containsValue(challenge.reference)){
        if(challenge['degree'] == user['degree'] || challenge['degree']=="todos"){
          switch(challenge['level']){
            case 1:
              return _getAppCard(Image.asset('images/bronze.png'), challenge, const Color.fromARGB(255, 114, 64, 7));
            case 5:
              return _getAppCard(Image.asset('images/silver.png'), challenge, Colors.grey);
            default:
              return _getAppCard(Image.asset('images/gold.png'),challenge, Colors.yellow[700]);
          }
        }else{return Container(height: 0.0,);}
      }else{return Container(height: 0.0,);}
    }else{return Container(height: 0.0,);}
  }
}