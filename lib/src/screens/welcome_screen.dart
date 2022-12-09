import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/home.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WelcomeScreen extends StatefulWidget {
  static const String routeName = '';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {  
  QueryDocumentSnapshot<Map<String, dynamic>>? _user;
  
  Future<void> _getUser()async {
    try{
      await Firebase.initializeApp();
      var user = await Authentication().getRightUser();
      var snap = await FirestoreService().getMessage(collectionName: "users");

      if (user != null){
        _user = snap.docs.firstWhere((element) => element["email"] == user.email);
        if(_user!["verified"]){
          await Future.delayed(const Duration(milliseconds: 200)).then((value){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
          });

        }
        else{
          Authentication().signOut();
        }
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
    }catch(e){
      Authentication().signOut();
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
    return FutureBuilder<void>(
      future: _getUser(),
      builder: (context, snapshot){
        return snapshot.connectionState == ConnectionState.waiting ? 
        Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,    
            children:<Widget>[
              // const Center(
              //   child: Text(
              //     "¡Hola!",
              //     style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold))),
              Image.asset('images/menthor_icon.png',height: 200.0,),
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
        ) : snapshot.connectionState == ConnectionState.done ? _fullPage() : Container(height: 0.0,);
      },
    );
  }

  Widget _fullPage(){
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(child: Image.asset('images/menthor_logo.png')),
            const SizedBox(height: 75.0,),
            AppButton(
              icon: Icons.account_circle,
              key: const ValueKey('emailSignInOpener'),
              colorText:Colors.white,
              color: const Color.fromARGB(255, 180, 50, 87),
              name: 'Iniciar sesión',
              onPressed: (){return Navigator.pushNamed(context, '/login');}
            ),
            AppButton(
              icon: Icons.add_circle,
              key: const ValueKey('emailSignUpOpener'),
              colorText:Colors.white,
              color: const Color.fromRGBO(179, 0, 51, 1.0),
              name: 'Registrarse',
              onPressed: (){ return Navigator.pushNamed(context, '/registration');}
            ),
          ]
        ),
      )
    );
  }
}