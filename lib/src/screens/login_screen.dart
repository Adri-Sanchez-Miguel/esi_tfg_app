import 'package:esi_tfg_app/src/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/mixins/validation_mixins.dart';
import 'package:esi_tfg_app/src/screens/profile.dart';
import 'package:esi_tfg_app/src/screens/team.dart';
import 'package:esi_tfg_app/src/screens/settings.dart';
import 'package:esi_tfg_app/src/screens/tutor.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with ValidationMixins{
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            Container(margin: const EdgeInsets.all(25.0)), 
            Image.asset('assets/images/logo_esi_titulo.png',height: 200.0),
            emailField(),
            passwordField(),
            // Widget específico para dar margin, esto nos da más flexibilidad
            Container(margin: const EdgeInsets.only(top: 25.0)), 
            submitField()
          ]
        )
      ),
    );
  }

  Widget emailField(){
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'you@example.com' 
      ),
      validator: validateEmail,
      onSaved: (value){
        
      },
    );
  }

  Widget passwordField(){
    return TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
      ),
      validator: validatePassword,
      onSaved: (value){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context){
              return MaterialApp(
                home:Home(),
                routes: <String, WidgetBuilder>{
                  Settings.routeName: (BuildContext context) => const Settings(),
                  Profile.routeName: (BuildContext context) => const Profile(),
                  Tutor.routeName: (BuildContext context) => const Tutor(),
                  Team.routeName: (BuildContext context) => const Team(),
                }
              );
            }
          )
        );
      },
    );
  }

  Widget submitField(){
    return ElevatedButton(
      onPressed: (){
        // La exclamación comprueba que no sea nulo el current state
        if(formKey.currentState!.validate()){
          formKey.currentState!.save();
        }
      }, 
      child: const Text("Submit"));
  }
}