import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/home.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:esi_tfg_app/src/services/storage_service.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PhotoDetail extends StatelessWidget {
  final File? imageFile;
  final String imageName;
  final bool method;
  final QueryDocumentSnapshot<Map<String, dynamic>>? challenge;
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  final Storage storage = Storage();
  PhotoDetail({Key? key, this.imageFile, required this.imageName, this.user, required this.method, this.challenge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding:const EdgeInsets.only(left: 10.0, right: 10.0, top: 40.0),
                      child: 
                        AppButton(
                        icon: Icons.arrow_back,
                        color: const Color.fromARGB(255, 180, 50, 87), 
                        onPressed: ()async{Navigator.pop(context);}, 
                        name: "Volver   ", 
                        colorText: Colors.white
                      )
                    ),
                    Padding(
                      padding:const EdgeInsets.only(left: 10.0, right: 10.0, top: 40.0),
                      child: 
                        AppButton(
                          icon: Icons.arrow_forward,
                          color: const Color.fromARGB(255, 180, 50, 87), 
                          onPressed: () async{
                            method ? _savePhoto() : _updatePublication();
                            await storage.uploadFile(imageFile, imageName);
                            await Future.delayed(const Duration(milliseconds: 200)).then((_) => {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()))
                            });
                          }, 
                          name: "Confirmar", 
                          colorText: Colors.white
                        )
                      ) 
                  ]
                ),
              ),
              Padding(
                padding:const EdgeInsets.only(top: 40.0, left: 15.0, right: 15.0),
                child: Image.file(
                  imageFile!,
                  fit: BoxFit.cover,
                ),
              ),
            ]
          )
        )
    );
  }

  void _savePhoto() async{
    await FirestoreService().update(document: user!.reference, collectionValues: {
      'image': imageName
    }); 
  }

  void _updatePublication() async{
    _updateUser();
    _createPublication(user!["email"]);
    await Fluttertoast.showToast(
      msg: "¡Reto conseguido!",
      fontSize: 20,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green[600]
    );
  }

  void _updateUser() async{
    Map<String, dynamic> challengesCompleted = user!['challenges_completed'];
    challengesCompleted.addAll({
      challenge!.reference.path : challenge!.reference,
    });
    await FirestoreService().update(document: user!.reference, collectionValues: {
      'challenges_completed': challengesCompleted,
      'coins': user!["coins"]+challenge!["level"],
      'status' : user!["status"]+challenge!["level"]
    }); 
  }

  void _createPublication(String email) async{
    String name =  challenge!["name"];
    String decider = "";
    if(challenge!["degree"] != "todos"){
        decider = user!["degree"];
    }
    await FirestoreService().save(collectionName: "publications", collectionValues: {
      'challenge': challenge!.reference.path,
      'user': email.toLowerCase(),
      'visibility': challenge!["users_visibility"],
      'decider': decider,
      'degree': challenge!["degree"],
      'title': "Reto conseguido: $name",
      'creation_date': DateTime.now(),
      'comentarios': {},
      'likes': {},
      'photo': imageName,
      'description': challenge!["explanation"],
    }); 
  }
}