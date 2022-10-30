import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:esi_tfg_app/src/widgets/app_modalbottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ChallengeDetail extends StatelessWidget {  
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  final QueryDocumentSnapshot<Map<String, dynamic>> challenge;
  const ChallengeDetail({Key? key, required this.challenge, this.user}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reto")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(child:Text(challenge['name'], style: const TextStyle(color: Color.fromARGB(255, 180, 50, 87), fontSize: 30.0, fontWeight: FontWeight.w700))),
            const SizedBox(height: 15.0,), 
            Text(challenge['explanation'], style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),),
            const Divider(thickness: 3.0, height: 30.0, color: Color.fromARGB(255, 180, 50, 87),),
            const Text("Disponible hasta:", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w700),),
            _getDate(challenge['end_date'].toDate()),
            const SizedBox(height: 20.0,),
            const Text("Nivel:", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w700),),
            _getLevel(challenge['level']),
            const SizedBox(height: 20.0, 
            child: Divider(thickness: 3.0, color: Color.fromARGB(255, 180, 50, 87),),),
            const SizedBox(height: 5.0,),
            !challenge['friendly'] ? const Text("Código QR:", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w700),): Container(height: 0.0,),
            const SizedBox(height: 10.0,),
            challenge['friendly'] ? _getButton(context) : _getQR(challenge["qr_key"]),
          ]
        )
      )
    );
  }
  
  Widget _getLevel(int level) {
    switch(level){
      case 1:
        return const Text("Bronce", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500));
      case 2:
        return const Text("Plata", style:  TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500));
      case 3:
        return const Text("Oro", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500));
      default:
        return const Text("Error", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500));
    }
  }

  Widget _getDate(DateTime time){
    if(time.year == 2039){
      return const Text("Siempre disponible", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
    }else{
      return Text(challenge['end_date'].toDate().toString(), style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
            
    }
  }

  Widget _getQR(String qr){
    return qr != "" ? Center(child: QrImage(
      data: qr,
      version: QrVersions.auto,
      size: 200.0,
    )): Container(height: 0.0,);
  }

  Widget _getButton(BuildContext context){
    return AppButton(
      icon: Icons.camera_alt,
      name: 'Reclamar reto mediante foto',
      colorText: Colors.white,
      color:const Color.fromRGBO(179, 0, 51, 1.0),
      onPressed: ()async{
        showModalBottomSheet(
          context: context, 
          builder: (BuildContext context){
            return ModalBottomSheet(method: false, user: user, challenge: challenge);
          }
        );
      }
    );
  }
}