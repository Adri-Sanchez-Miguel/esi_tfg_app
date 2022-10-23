import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/detail/photo_detail.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ModalBottomSheet extends StatefulWidget {
  final bool method;
  final QueryDocumentSnapshot<Map<String, dynamic>>? challenge;
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  const ModalBottomSheet({Key? key, this.user, required this.method, this.challenge}) : super(key: key);

  @override
  State<ModalBottomSheet> createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet> {
  String _imageName = "";
  File? imageFile;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 350.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Center(child: Text("Elija cómo hacer la foto", style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w700),),),
            Padding(
              padding:const EdgeInsets.only(left: 100.0, right: 100.0, top: 30.0),
              child: AppButton(
                icon: Icons.photo,
                color: const Color.fromARGB(255, 180, 50, 87), 
                onPressed: ()async{
                  _seleccionGaleria();
                }, 
                name: "Seleccionar foto", 
                colorText: Colors.white)
            ),
            Padding(
              padding:const EdgeInsets.only(left: 100.0, right: 100.0),
              child: AppButton(
                icon: Icons.camera_alt,
                color: const Color.fromARGB(255, 180, 50, 87), 
                onPressed: ()async{ 
                  _hazFoto();
                }, 
                name: "Haz una foto", 
                colorText: Colors.white)
              ) 
          ]
        ),
      ),
    );
  }

  void _seleccionGaleria() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        _imageName = pickedFile.name;
      });
      await Future.delayed(const Duration(milliseconds: 100)).then((_) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoDetail(imageFile: imageFile, imageName: _imageName, user: widget.user, method: widget.method, challenge: widget.challenge,)));
      });

    }
  }

  void _hazFoto() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        _imageName = pickedFile.name;
      });
      await Future.delayed(const Duration(milliseconds: 100)).then((_) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoDetail(imageFile: imageFile, imageName: _imageName, user: widget.user, method: widget.method, challenge: widget.challenge)));
      });
    }
  }
}