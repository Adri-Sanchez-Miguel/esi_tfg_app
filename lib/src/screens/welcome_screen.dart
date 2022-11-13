import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';

class WelcomeScreen extends StatefulWidget {
  static const String routeName = '';
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {  
  @override
  Widget build(BuildContext context) {
    return _fullPage();
  }

  Widget _fullPage(){
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(child: Image.asset('images/menthor_logo.png')),
            const SizedBox(height: 75.0,),
            AppButton(
              key: const ValueKey('emailSignInOpener'),
              colorText:Colors.white,
              color: const Color.fromARGB(255, 180, 50, 87),
              name: 'Iniciar sesión',
              onPressed: (){return Navigator.pushNamed(context, '/login');}
            ),
            AppButton(
              key: const ValueKey('emailSignUpOpener'),
              colorText:Colors.white,
              color: const Color.fromRGBO(179, 0, 51, 1.0),
              name: 'Registrarse',
              onPressed: (){ return Navigator.pushNamed(context, '/registration');}
            ),
          ]
        ),
      )
    );
  }
}