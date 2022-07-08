import 'package:esi_tfg_app/src/screens/selectdegree_screen.dart';
import 'package:esi_tfg_app/src/screens/selectteam_screen.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/bloc/bloc.dart';
import 'package:esi_tfg_app/src/screens/publication_screen.dart';
import 'package:esi_tfg_app/src/screens/home.dart';
import 'package:esi_tfg_app/src/screens/login_screen.dart';
import 'package:esi_tfg_app/src/screens/profile_screen.dart';
import 'package:esi_tfg_app/src/screens/registration_screen.dart';
import 'package:esi_tfg_app/src/screens/settings_screen.dart';
import 'package:esi_tfg_app/src/screens/tutor_screen.dart';
import 'package:esi_tfg_app/src/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Cambiar forma registrar rol en usuario (combobox)
  // Comentario en publicacion (ver si hacer como respuesta) y likes (?)
  // Dejar bonitas ventanas
  // Buscar lo de las imágenes y el QR
  // Hacer ventanas para introducir retos y publicaciones y reclamarlos
  // Comprobar en iOS 
  // Testing
  // Comentar las clases y métodos
  // Dejar la app en español

  runApp(
    Provider(
      create: (context) => Bloc(),
      child: MaterialApp(
        home: const WelcomeScreen(),
        theme: ThemeData(
          textTheme: const TextTheme(
            bodyText1: TextStyle(color: Colors.black45)
          )
        ),
        initialRoute: WelcomeScreen.routeName,
        routes: <String, WidgetBuilder>{
          SelectDegree.routeName:(BuildContext context) => const SelectDegree(),
          SelectTeam.routeName: (BuildContext context) => const SelectTeam(),
          LoginScreen.routeName: (BuildContext context) => const LoginScreen(),
          WelcomeScreen.routeName: (BuildContext context) => const WelcomeScreen(),
          RegistrationScreen.routeName: (BuildContext context) => const RegistrationScreen(),
          Home.routeName:  (BuildContext context) => const Home(),
          PublicationsScreen.routeName: (BuildContext context) => const PublicationsScreen(),
          Settings.routeName: (BuildContext context) => const Settings(),
          Profile.routeName: (BuildContext context) => const Profile(),
          Tutor.routeName: (BuildContext context) => const Tutor(),
        },
      )
    )
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}