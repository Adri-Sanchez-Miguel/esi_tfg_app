import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:esi_tfg_app/src/widgets/app_modalbottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class ChallengeDetail extends StatefulWidget {  
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  final QueryDocumentSnapshot<Map<String, dynamic>> challenge;
  const ChallengeDetail({Key? key, required this.challenge, this.user}) : super(key: key);
  
  @override
  State<ChallengeDetail> createState() => _ChallengeDetailState();
}

class _ChallengeDetailState extends State<ChallengeDetail> {
  ScreenshotController screenshotController = ScreenshotController(); 

  @override
  void initState() {
    super.initState();
  }

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
            Center(child:Text(widget.challenge['name'], style: const TextStyle(color: Color.fromARGB(255, 180, 50, 87), fontSize: 30.0, fontWeight: FontWeight.w700))),
            const SizedBox(height: 15.0,), 
            Text(widget.challenge['explanation'], style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),),
            const Divider(thickness: 3.0, height: 30.0, color: Color.fromARGB(255, 180, 50, 87),),
            const Text("Disponible hasta:", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w700),),
            _getDate(widget.challenge['end_date'].toDate()),
            const SizedBox(height: 20.0,),
            const Text("Nivel:", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w700),),
            _getLevel(widget.challenge['level']),
            const SizedBox(height: 20.0, 
            child: Divider(thickness: 3.0, color: Color.fromARGB(255, 180, 50, 87),),),
            const SizedBox(height: 5.0,),
            !widget.challenge['friendly'] ? 
               widget.challenge['users_visibility'] != widget.user!['role'] ? 
                  const Text("Código QR:", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w700),): Container(height: 0.0,)
              : Container(height: 0.0,),
            const SizedBox(height: 10.0,),
            widget.challenge['friendly'] ? Container(height: 0.0,): _getCapture(),
            widget.challenge['friendly'] ? _getButton(context) : _getQR(widget.challenge["qr_key"]),
          ]
        )
      )
    );
  }
  
  Widget _getLevel(int level) {
    switch(level){
      case 1:
        return Image.asset('images/bronze.png',height: 70.0);
      case 5:
        return Image.asset('images/silver.png',height: 70.0);
      case 20:
        return Image.asset('images/gold.png',height: 70.0);
      default:
        return const Text("Error", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500));
    }
  }

  Widget _getDate(DateTime time){
    if(time.year == 2039){
      return const Text("Siempre disponible", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
    }else{
      return Text(widget.challenge['end_date'].toDate().toString(), style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
            
    }
  }

  Widget _getQR(String qr){
    return widget.challenge['users_visibility'] != widget.user!['role'] ? 
    Center(
      child: Screenshot(
        controller: screenshotController,
        child:QrImage(
          backgroundColor: Colors.white,
          data: qr,
          version: QrVersions.auto,
          size: 200.0,
        )
      )
    ): const Center(child: Text("¡Reclama este reto escaneando su QR!", style: TextStyle(fontSize: 18.0,  fontWeight: FontWeight.w500)));
  }

  Widget _getButton(BuildContext context){
    return widget.challenge['users_visibility'] != widget.user!['role'] ? 
    AppButton(
      icon: Icons.camera_alt,
      name: 'Reclamar reto mediante foto',
      colorText: Colors.white,
      color:const Color.fromRGBO(179, 0, 51, 1.0),
      onPressed: ()async{
        showModalBottomSheet(
          context: context, 
          builder: (BuildContext context){
            return ModalBottomSheet(method: false, user: widget.user, challenge: widget.challenge);
          }
        );
      }
    ): const Center(child: Text("¡Reclama este reto escaneando su QR!", style: TextStyle(fontSize: 18.0,  fontWeight: FontWeight.w500)));
  }

  Widget _getCapture(){
    return widget.challenge['users_visibility'] != widget.user!['role'] ?  
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: AppButton(
        onPressed: () async{
          screenshotController.capture().then((capturedImage) async {
              if(capturedImage != null){
                await saveImage(capturedImage);
                _toast("QR almacenado en la galería", Colors.green[800]);
              }
            }).catchError((onError) {
            _toast("Error guardando el QR", Colors.red[400]);
          });
        }, 
        colorText: Colors.white,
        color:const Color.fromRGBO(179, 0, 51, 1.0),
        name: 'Guarda el QR en tu galería',
      ),
    ): Container(height: 0.0);
  }

  Future<bool?> _toast(String message, Color? color){
    return Fluttertoast.showToast(
      msg: message,
      fontSize: 20,
      gravity: ToastGravity.CENTER,
      backgroundColor: color
    );
  }

  Future<void> saveImage(Uint8List capturedImage)async{
    await [Permission.storage].request();

    String seconds = DateTime.now().microsecondsSinceEpoch.toString();
    String fileName = 'qr_$seconds';

    await ImageGallerySaver.saveImage(capturedImage, name: fileName);
  }
}