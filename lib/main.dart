import 'package:esi_tfg_app/src/screens/selectdegree_screen.dart';
import 'package:esi_tfg_app/src/screens/selectteam_screen.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/bloc/bloc.dart';
import 'package:esi_tfg_app/src/screens/publication_screen.dart';
import 'package:esi_tfg_app/src/screens/home.dart';
import 'package:esi_tfg_app/src/screens/login_screen.dart';
import 'package:esi_tfg_app/src/screens/reclamar_screen.dart';
import 'package:esi_tfg_app/src/screens/registration_screen.dart';
import 'package:esi_tfg_app/src/screens/settings_screen.dart';
import 'package:esi_tfg_app/src/screens/new_message_screen.dart';
import 'package:esi_tfg_app/src/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Tips: CalendarDate (tip 28 -> 35 Flutter tips that will change your life)
  // Comentario en publicacion (ver si hacer como respuesta y se almacenan en la publicación) 
  // Dejar bonitas ventanas
  // Buscar lo de las imágenes y el QR
  // Hacer ventanas para introducir retos y publicaciones y reclamarlos
  // Comprobar en iOS 
  // Testing
  // Comentar las clases y métodos
  // Dejar las menos warnings posibles
  // Cambiar visibilidad para que pueda ser para mentores, profesores y mentorizados
  // Acordarse de que cuando se crea un reto se crea una publicación asociada
  
  runApp(
    Provider(
      create: (context) => Bloc(),
      child: MaterialApp(
        home: const WelcomeScreen(),
        theme: ThemeData(
          appBarTheme: const AppBarTheme(backgroundColor: Color.fromARGB(255, 180, 50, 87)),
          textTheme: const TextTheme(
            bodyText1: TextStyle(color: Colors.black45)
          ),
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
          ReclamarLogro.routeName: (BuildContext context) => const ReclamarLogro(),
          NuevoMensaje.routeName: (BuildContext context) => const NuevoMensaje(),
        },
      )
    )
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}