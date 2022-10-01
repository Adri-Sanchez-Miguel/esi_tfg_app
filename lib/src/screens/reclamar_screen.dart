import 'dart:io';

import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ReclamarLogro extends StatefulWidget {
  static const String routeName = "/achieve"; 
  const ReclamarLogro({Key? key}) : super(key: key);

  @override
  State<ReclamarLogro> createState() => _ReclamarLogroState();
}

class _ReclamarLogroState extends State<ReclamarLogro>{
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
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
        title: const Text("Reclamar logro"),
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
        barcode != null ? 'Código: ${barcode!.code}' :'Escanea un QR',
        maxLines: 3,
      )
    );
  }

  Widget sendResult(){
    return AppButton( 
      color: barcode != null ? const Color.fromRGBO(179, 0, 51, 1.0): Colors.black54, 
      onPressed: barcode != null ? ()async{}: null, 
      name: "Comprobar reto", 
      colorText: barcode != null ? Colors.white : Colors.white54,
    );
  }
}