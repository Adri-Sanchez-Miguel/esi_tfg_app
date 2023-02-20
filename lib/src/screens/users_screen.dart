import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
    _users = await FirestoreService().getOrderedMessage(field: "status",collectionName: "users");
    if (user != null){
      if(mounted){
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
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            elevation: 10.0,
            toolbarHeight: 1,
            automaticallyImplyLeading: false,
            bottom: const TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              tabs: [
                Tab(icon: Icon(Icons.book),text: "Mi grado",),
                Tab(icon: Icon(Icons.double_arrow),text: "Todos",)
              ])
            ),
          body: TabBarView(
            children: [
              ModalProgressHUD(
                inAsyncCall: _showSpinner,
                child: SafeArea(
                  child: _getMainWidget(true)
                ),
              ),
              ModalProgressHUD(
                inAsyncCall: _showSpinner,
                child: SafeArea(
                  child: _getMainWidget(false)
                ),
              )
            ]
          )
      )
    );
  }

  Widget _getMainWidget(bool decider){
    return ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                        if(mounted){
                          setState(() {
                            _user = aux;
                          });
                        }
                        
                      },
                      child: Text("Buscar", style: _sendButtonStyle,)
                    ),
                  ),
                ],
              ),
              _users!= null ? _getUsers(_user, decider) : const Text("Cargando..."),
            ],
          ),
        ),
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

  Widget _getUsers(String usersSearched, bool decider){
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirestoreService().getOrderedMessage(field: "status",collectionName: "users"),
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
                _getItems(context, snapshot.data!.docs[index], usersSearched, decider),
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
      active: false,
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
      subtitle: Text('Rol: $role\nExperiencia: $level px', style: const TextStyle(fontSize: 15.0)),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetail(user: user, loggedInUser: loggedInUser,)));
      }
    );
  }

  Widget _getItems(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> user, String usersSearched, bool decider){
    Widget? icon; 
    QueryDocumentSnapshot<Map<String, dynamic>> myUser = _users!.docs.firstWhere((element) => element["email"] == loggedInUser.email);
    if(user["image"] != ""){
      icon = _getPhoto(user["image"], 300.0);
    }else{
      icon = const Icon(Icons.perm_identity_outlined);
    }
    if(user['email'] != loggedInUser.email){
      if(usersSearched == ""){
        if (decider){
          if(myUser["degree"] == user["degree"]){
            return _getAppCard(icon,user, Colors.black);
          }else{return Container(height: 0.0,);}
        }else{        
          return _getAppCard(icon,user, Colors.black);
        }
      }else{
        if(user['email'].contains(usersSearched)){
          if (decider){
            if(myUser["degree"] == user["degree"]){
              return _getAppCard(icon,user, Colors.black);
            }else{return Container(height: 0.0,);}
          }else{        
            return _getAppCard(icon,user, Colors.black);
          }
        }else{return Container(height: 0.0,);}
      }
    }else{return Container(height: 0.0,);}
  }

  Widget _getPhoto(String name, double height){
    try{
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
                width: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    key: ValueKey<String>(snapshot.data!),
                    imageUrl: snapshot.data!,
                    placeholder: (context, url) => Platform.isAndroid ? 
                      const CircularProgressIndicator() 
                      : const CupertinoActivityIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              )
            ]
          )
        )
        : Container(height: 0.0,);
      },
    );
    }catch(e){
      Fluttertoast.showToast(
        msg: e.toString(),
        fontSize: 20,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[400]
      );
      return Container(height: 0.0,);
    }
  }
}