import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/detail/user_detail.dart';
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

class UsersScreen extends StatefulWidget {
  static const String routeName = '/users';

  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late User loggedInUser;
  QuerySnapshot<Map<String, dynamic>>? _users;
  String _user = "";
  bool _showSpinner = false; 
  late TextEditingController _emailController;
  final Storage storage = Storage();

  @override
  void initState() {
    super.initState();
    
    _emailController = TextEditingController();
    _getRightUser();
  }

    @override
  void dispose(){
    super.dispose();
    _emailController.dispose();
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
                    child: _emailField()
                  ),
                  Padding(
                    padding:  const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onPrimary, 
                        backgroundColor: const Color.fromARGB(255, 180, 50, 87),
                      ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
                      onPressed: (){
                        var aux = _emailController.text;
                        _emailController.clear;
                        setState(() {
                          _user = aux;
                        });
                      },
                      child: Text("Buscar", style: _sendButtonStyle,)
                    ),
                  ),
                ],
              ),
              _users!= null ? _getUsers(_user) : const Text("Cargando..."),
            ],
          ),
        ),
      )
    );
  }

  Widget _emailField(){
    return AppTextField(
      error: "",
      icon: const Icon(Icons.search),
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      hint: "Email",
      label: "Buscar usuario",
      obscureText: false
    ); 
  }

  Widget _getUsers(String usersSearched){
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirestoreService().getMessage(collectionName: "users"),
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
                _getItems(context, snapshot.data!.docs[index], usersSearched),
            )
          )
        : Container(height: 0.0,);
      },
    );
  }

  Widget _getAppCard(Widget? icon, QueryDocumentSnapshot<Map<String, dynamic>> user, Color colorDecoration){
    String username = user['email'];
    Color background = Colors.white;
    Color decoration = colorDecoration;
    String role = user['role'];
    String level = user['status'].toString();

    return AppCard(
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
            TextSpan(text: '$username\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ],
        ),
      ),
      subtitle: Text('Rol: $role\nLevel: $level', style: const TextStyle(fontSize: 15.0)),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetail(user: user)));
      }
    );
  }

  Widget _getItems(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> user, String usersSearched){
   Widget? icon; 
   if(user["image"] != ""){
      icon = _getPhoto(user["image"], 300.0);
    }else{
      icon = const Icon(Icons.perm_identity_outlined);
    }
    if(user['email'] != loggedInUser.email){
      if(usersSearched == ""){
        return _getAppCard(icon,user, Colors.black);
      }else{
        if(user['email'].contains(usersSearched)){
          return _getAppCard(icon,user, Colors.black);
        }else{return Container(height: 0.0,);}
      }
    }else{return Container(height: 0.0,);}
  }

  Widget _getPhoto(String name, double height){
    return FutureBuilder(
      future: storage.photoURL(name),
      builder: (context, AsyncSnapshot<String> snapshot){
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
        ) : snapshot.hasData ? Center(
            child:Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox (
                height: height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover
                    )
                ),
              )
            ]
          )
        )
        : Container(height: 0.0,);
      },
    );
  }
}