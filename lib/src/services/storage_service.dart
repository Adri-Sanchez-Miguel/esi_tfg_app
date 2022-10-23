import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Storage{
  final firebase_storage.FirebaseStorage storage =
   firebase_storage.FirebaseStorage.instance;

   Future<void> uploadFile(File? file, String name) async{
    try{
      await storage.ref(name).putFile(file!);
    } on firebase_core.FirebaseException catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        fontSize: 20,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[400]
      );
    }
  }

  Future<String> photoURL(String photoName) async{
    String downloadURl = await storage.ref(photoName).getDownloadURL();
    
    return downloadURl;
  }

  Future<void> deleteURL(String photoName) async{
    await storage.ref(photoName).delete();
  }
}