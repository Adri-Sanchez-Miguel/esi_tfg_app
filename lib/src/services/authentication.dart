import 'package:firebase_auth/firebase_auth.dart';
import 'package:esi_tfg_app/src/model/auth_request.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Authentiaction{
  final _auth = FirebaseAuth.instance;

  Future<AuthenticationRequest> createUser({String email = "", String password = ""}) async{
    AuthenticationRequest authRequest = AuthenticationRequest();
    try {
      var user = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if(user != null){
        authRequest.success = true;
      }
    }
    catch(e){
        _mapErrorMessage(authRequest, e.toString());
    }
    return authRequest;
  }

    Future<User?> getRightUser() async {
      try{
        return await _auth.currentUser!;
      }catch(e){
        Fluttertoast.showToast(
          msg: e.toString(),
          fontSize: 20,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red[400]
        );
      }
      return null;
    }

    Future<AuthenticationRequest> loginUser({String email = "", String password = ""}) async {
      AuthenticationRequest authRequest = AuthenticationRequest();
      try{
        var user = await _auth.signInWithEmailAndPassword(email: email, password: password);
        if(user != null){
          authRequest.success = true;
        }
      }catch(e){
        _mapErrorMessage(authRequest, e.toString());
      }
      return authRequest;
    }

    Future<void> signOut() async{
      try{
        return await _auth.signOut();
      }catch(e){
        Fluttertoast.showToast(
          msg: e.toString(),
          fontSize: 20,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red[400]
        );
      }
    }

    void _mapErrorMessage(AuthenticationRequest authRequest, String code){
      switch(code){
        case '[firebase_auth/unknown] com.google.firebase.FirebaseException: An internal error has occurred. [ Connection reset ]':
          authRequest.errorMessage = "Error de red, un error ha ocurrido al conectar con la base de datos, inténtelo de nuevo";
          break;
        case '[firebase_auth/email-already-in-use] The email address is already in use by another account.':
          authRequest.errorMessage = "El usuario ya está registrado";
          break;
        case '[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.':
          authRequest.errorMessage = "Usuario no encontrado";
          break;
        case '[firebase_auth/wrong-password] The password is invalid or the user does not have a password.':
          authRequest.errorMessage = "Contraseña incorrecta";
          break;
        case '[firebase_auth/network-request-failed] A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          authRequest.errorMessage = "Error de red, no se ha encontrado ninguna conexión";
          break;
        default:
        authRequest.errorMessage = code;
      }
    }
}