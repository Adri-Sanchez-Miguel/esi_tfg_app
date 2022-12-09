import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ReclamarLogro extends StatefulWidget {
  static const String routeName = "/achieve"; 
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;

  const ReclamarLogro({Key? key, this.user}) : super(key: key);

  @override
  State<ReclamarLogro> createState() => _ReclamarLogroState();
}

class _ReclamarLogroState extends State<ReclamarLogro>{
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  QueryDocumentSnapshot<Map<String, dynamic>>? _challenge;
  Barcode? barcode;

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async{
    super.reassemble();
    
    if(Platform.isAndroid){
      await controller!.pauseCamera();
    } else if (Platform.isIOS) {
      await controller!.resumeCamera();
    }
    await controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reclamar reto"),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          buildQrView(context),
          Positioned(
            bottom: 100,
            child: showResult()
          ),
          Positioned(
            bottom: 5,
            child: sendResult()
          ),
        ]
      ),
    );
  }

  Widget buildQrView(BuildContext context){
    return QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.white,
        borderLength: 20,
        borderRadius: 10,
        borderWidth: 10,
        cutOutSize: MediaQuery.of(context).size.width * 0.7,
      ),
    );
  }

  void onQRViewCreated(QRViewController controller){
    setState(() => this.controller = controller);
    controller.resumeCamera();
    controller.scannedDataStream.listen((barcode) {
      setState(() {
        this.barcode = barcode;
      });
    });
  }

  Widget showResult(){
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white24,
      ),
      child: Text(
        barcode != null ? '¡Código encontrado!' :'Escanea un QR',
        maxLines: 3,
      )
    );
  }

  Widget sendResult(){
    return AppButton( 
      icon: Icons.search,
      color: barcode != null ? const Color.fromRGBO(179, 0, 51, 1.0): Colors.black54, 
      onPressed: barcode != null ? ()async{
        var snap = await FirestoreService().getMessage(collectionName: "challenges");
        try{
          if(snap.docs.any((element) => element["qr_key"] == barcode!.code)){
            _challenge = snap.docs.firstWhere((element) => element["qr_key"] == barcode!.code);
            Map<String, dynamic> challengesCompleted = widget.user!['challenges_completed'];
            if(!challengesCompleted.containsValue(_challenge!.reference)){
              if(_challenge!['users_visibility'] == widget.user!['role'] || _challenge!['users_visibility']=="todos"){
                String name = _challenge!["name"];
                int level = _challenge!["level"];

                _toast("¡Enhorabuena! Reto '$name' conseguido. +$level coins", Colors.green[800]);
                challengesCompleted.addAll({
                  _challenge!.reference.path : _challenge!.reference,
                });

                await FirestoreService().update(document: widget.user!.reference, collectionValues: {
                  'challenges_completed': challengesCompleted,
                  'coins': widget.user!["coins"]+_challenge!["level"],
                  'status' : widget.user!["status"]+_challenge!["level"]
                }); 
                _createPublication(widget.user!["email"]);
                await Future.delayed(const Duration(milliseconds: 100)).then((_) {
                  Navigator.popAndPushNamed(context, "/home");
                });
              }else{
                _toast("Este reto no está registrado para tu rol.", Colors.red[400]);
              }
            }else{
              _toast("Código no registrado o que ya has reclamado antes", Colors.red[400]);
            }
          }
        }catch(e){
          _toast(e.toString(), Colors.red[400]);
        }
      }: null, 
      name: "Comprobar clave", 
      colorText: barcode != null ? Colors.white : Colors.white54,
    );
  }

  void _createPublication(String email) async{
    String email =  _challenge!["email"];
    String decider = "";
    if(_challenge!["degree"] != "todos"){
        decider = widget.user!["degree"];
    }
    await FirestoreService().save(collectionName: "publications", collectionValues: {
      'challenge': _challenge!.reference.path,
      'user': email.toLowerCase(),
      'visibility': _challenge!["users_visibility"],
      'decider': decider,
      'degree': _challenge!["degree"],
      'title': "Reto conseguido: $email",
      'creation_date': DateTime.now(),
      'comentarios': {},
      'likes': {},
      'photo': "",
      'description': _challenge!["explanation"],
    }); 
  }

  Future<bool?> _toast(String message, Color? color){
    return Fluttertoast.showToast(
      msg: message,
      fontSize: 20,
      gravity: ToastGravity.CENTER,
      backgroundColor: color
    );
  }
}