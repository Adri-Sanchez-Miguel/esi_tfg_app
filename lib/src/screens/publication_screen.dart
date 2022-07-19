import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/detail/publication_detail.dart';
import 'package:esi_tfg_app/src/widgets/app_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class PublicationsScreen extends StatefulWidget {
  static const String routeName = '/publications';

  const PublicationsScreen({Key? key}) : super(key: key);

  @override
  State<PublicationsScreen> createState() => _PublicationsScreenState();
}

class _PublicationsScreenState extends State<PublicationsScreen> {
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
    var user = await Authentiaction().getRightUser();
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
                _getPublications(),
              ],
            ),
          ),
        )
      );
    }else{
      // Retocar el texto que indique que se está cargando
      return const Text("Cargando...");
    }
  }

  Widget _getPublications(){
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: _futurePublications(),
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
        )        : snapshot.hasData ? Flexible(
          child: RefreshIndicator(
            onRefresh: () async{
              setState((){
                _getPublications();
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

  Future<QuerySnapshot<Map<String, dynamic>>>? _futurePublications() async{
    await Future.delayed(const Duration(milliseconds: 500));
    return await FirestoreService().getOrderedMessage(field: "creation_date", collectionName: "publications");
  }

  Widget _getAppCard(Widget? icon, QueryDocumentSnapshot<Map<String, dynamic>> publication, Color colorDecoration){
    String username = publication['user'];
    Map<String, dynamic> likes = publication['likes'];
    bool liked = likes.containsValue(loggedInUser.email);
    Color background = Colors.white;
    Color decoration = colorDecoration;
    String title = publication['title'];
    String description = publication['description'];
    if (username == loggedInUser.email){
      username = "Tú";
      background = const Color.fromARGB(255, 180, 50, 87);
      decoration = Colors.white;
    }
    return AppCard(
      trailing: IconButton(
        tooltip: "Like the publication",
        icon: liked ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border_rounded),
        color: const Color.fromARGB(255, 180, 50, 87), 
        onPressed: () {
          setState(() {
            // liked = !liked;
            _changeLike(liked, publication, likes);
          });
        },
      ),
      color: background,
      radius: 3.0,
      borderColor: Colors.black,
      iconColor: decoration,
      textColor: decoration,
      leading: icon,
      title: Text.rich(
        TextSpan(
          text: '', 
          children: <TextSpan>[
            TextSpan(text: '$title\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
            TextSpan(text: username, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15.0)),
          ],
        ),
      ),
      subtitle: Text('\n$description'),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => PublicationDetail(publication: publication)));
      }
    );
  }

  void _changeLike(bool liked, QueryDocumentSnapshot<Map<String, dynamic>> publication, Map<String, dynamic> likes) async{
    if(liked){
      // quitar al usuario de la base de datos
      likes.remove(loggedInUser.email);
      await FirestoreService().update(document: publication.reference, collectionValues: {
        'likes': likes,
      });
    }else{
      // añadir al usuario de la base de datos
      likes.addAll({
          loggedInUser.email! : loggedInUser.email
      });
      await FirestoreService().update(document: publication.reference, collectionValues: {
       'likes': likes,
      });
    }
  }


  Widget _getItems(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> publication){
    var user = _users!.docs.firstWhere((element) => element["email"] == loggedInUser.email);
    switch(publication['visibility']){
      case 'team':
        if(publication['decider'] == user['team']){
          return _getAppCard(const Icon(Icons.work), publication, Colors.teal);
        }else{
          return Container(
            height: 0.0,
          );
        }
      case 'degree':
        if(publication['decider'] == user['degree']){
          return _getAppCard(const Icon(Icons.auto_stories), publication, Colors.purple);
        }else{
          return Container(
            height: 0.0,
          );
        }
      case 'mentor':
        if(user['role'] == "mentor"){
          return _getAppCard(const Icon(Icons.group), publication, Colors.indigo);
        }else{
          return Container(
            height: 0.0,
          );
        }
      case 'profesor':
        if(user['role'] == "profesor"){
          return _getAppCard(const Icon(Icons.group), publication, Colors.indigo);
        }else{
          return Container(
            height: 0.0,
          );
        }
      case 'mentorizado':
        if(user['role'] == "mentorizado"){
          return _getAppCard(const Icon(Icons.group), publication, Colors.indigo);
        }else{
          return Container(
            height: 0.0,
          );
        }
      default:
        return _getAppCard(const Icon(Icons.task_alt_rounded),publication, Colors.black);
    }
  }  
}