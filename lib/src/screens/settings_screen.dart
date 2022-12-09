import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/widgets/app_card.dart';
import 'package:esi_tfg_app/src/widgets/app_modalbottomsheet.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  static const String routeName = "/configuracion"; 
  const SettingsScreen({Key? key, this.user}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppCard(
            active: false,
            color: Colors.white,
            radius: 3.0,
            borderColor: Colors.black,
            iconColor: Colors.black,
            textColor: Colors.black,
            leading: const Icon(Icons.person),
            title: const Text.rich(
              TextSpan(
                text: '', 
                children: <TextSpan>[
                  TextSpan(text: 'Cambiar foto de perfil\n', style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                ],
              ),
            ),
            subtitle: const Text('Selecciona una nueva foto o quite la que ya tiene', style: TextStyle(fontSize: 15.0)),
            onTap: (){
              showModalBottomSheet(
                context: context, 
                builder: (BuildContext context){
                  return ModalBottomSheet(method: true, user: widget.user);
                }
              );
            }
          )
        ]
      )
    );
  }
}