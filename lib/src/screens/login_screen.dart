import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/home.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:esi_tfg_app/src/bloc/bloc.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:esi_tfg_app/src/widgets/app_errormessage.dart';
import 'package:esi_tfg_app/src/widgets/app_texfield.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter/cupertino.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  String _email = "", _password = "", _errorMessage= "";
  late FocusNode _focusNode;
  bool _showSpinner = false, showable = false; 
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  QueryDocumentSnapshot<Map<String, dynamic>>? _user;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _emailController = TextEditingController();
   _passwordController = TextEditingController();
   _getEmail();
  }

  @override
  void dispose(){
    super.dispose();
    _focusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

   void _getEmail() async {
    try{
      await Future.delayed(const Duration(milliseconds: 2000));
      var user = await Authentication().getRightUser();
      var snap = await FirestoreService().getMessage(collectionName: "users");

      if (user != null){
        setState(() {
          _user = snap.docs.firstWhere((element) => element["email"] == user.email);
          if(_user!["verified"]){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
          }
          else{
            showable = true;
            Authentication().signOut();
          }
        });
      }else {
        setState(() {
          showable = true;
        });
      }
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

  void setSpinnersStatus(bool status){
    setState(() {
      _showSpinner = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showable){
      return _fullPage();
    }else{
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,    
          children:<Widget>[
            const Center(child:Text("Comprobando su sesión...")),
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
      );
    }
  }

  Widget _fullPage(){
    final bloc = Provider.of<Bloc>(context);
    _emailController.text = "";
    _passwordController.text = "";
    bloc.changeEmail;
    bloc.changePassword;
    return Scaffold(
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Flexible(child: Image.asset('images/menthor_logo.png')),
                  const SizedBox(height: 30.0,),
                  _emailField(bloc),
                  const SizedBox(height: 15.0,),
                  _passwordField(bloc),
                  const SizedBox(height: 15.0,),
                  _submitButton(bloc),
                  _showErrorMessage(),
                  const SizedBox(height: 10.0,),
                  _resetPassword()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailField(Bloc bloc){
    return StreamBuilder(
      stream: bloc.email,
      builder: (context, snapshot) {
        return AppTextField(
          key: const ValueKey('emailSignInField'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          focusNode: _focusNode,
          hint: "Tu email",
          label: "Email",
          error: snapshot.error as String?,
          onChanged: bloc.changeEmail,
          obscureText: false
        );
      }
    );    
  }

  Widget _passwordField(Bloc bloc){
    return StreamBuilder(
      stream: bloc.password,
      builder: (context, snapshot) {
        return AppTextField(
          key: const ValueKey('passwordSignInField'),
          controller: _passwordController,
          hint: "Tu contraseña",
          label: "Contraseña",
          error: snapshot.error as String?,
          onChanged: bloc.changePassword,
          obscureText: true,
        );
      }
    );
  }

  Widget _submitButton(Bloc bloc){
    return StreamBuilder(
      stream: bloc.submitValid,
      builder: (context, snapshot){
        return AppButton(
          color: snapshot.hasData && _emailController.text != "" && _passwordController.text != "" ? const Color.fromARGB(255, 180, 50, 87): Colors.black54,
          colorText: snapshot.hasData && _emailController.text != "" && _passwordController.text != "" ? Colors.white: Colors.white54,
          name: 'Iniciar sesión',
          onPressed: snapshot.hasData && _emailController.text != "" && _passwordController.text != "" ? ()async{
            _email = bloc.submitEmail();
            _password = bloc.submitPassword();
            try {
              setSpinnersStatus(true);
              var auth = await Authentication().loginUser(email: _email, password: _password);
              if (auth.success){   
                await Future.delayed(const Duration(milliseconds: 2000)).then((_){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
                  _emailController.text = "";
                  _passwordController.text = "";
                  bloc.changeEmail;
                  bloc.changePassword;
                  FocusScope.of(context).requestFocus(_focusNode);
                });
              }else{
                setState(() {
                  _errorMessage = auth.errorMessage;
                }
                );
              }
              setSpinnersStatus(false);
            }catch(e){
              Fluttertoast.showToast(
                msg: e.toString(),
                fontSize: 20,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.red[400]
              );
            }
          } : null, 
        );
      }
    );
  }

  Widget _showErrorMessage(){
    if(_errorMessage.isNotEmpty){
      return ErrorMessage(errorMessage: _errorMessage);
    }else{
      return Container(
        height: 0.0,
      );
    }
  }

  Widget _resetPassword(){
    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, "/password");
      },
      child: Text("He olvidado mi contraseña",
        textAlign: TextAlign.center,
        style: TextStyle(
          decoration: TextDecoration.underline,
          color: Colors.blue[800]
        ),
      ),
    );
  }
}