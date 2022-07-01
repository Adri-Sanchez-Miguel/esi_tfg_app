import 'package:esi_tfg_app/src/screens/selectdegree_screen.dart';
import 'package:esi_tfg_app/src/screens/selectteam_screen.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/bloc/bloc.dart';
import 'package:esi_tfg_app/src/screens/chat_screen.dart';
import 'package:esi_tfg_app/src/screens/home.dart';
import 'package:esi_tfg_app/src/screens/login_screen.dart';
import 'package:esi_tfg_app/src/screens/profile_screen.dart';
import 'package:esi_tfg_app/src/screens/registration_screen.dart';
import 'package:esi_tfg_app/src/screens/settings_screen.dart';
import 'package:esi_tfg_app/src/screens/team_screen.dart';
import 'package:esi_tfg_app/src/screens/tutor_screen.dart';
import 'package:esi_tfg_app/src/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {

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
          ChatScreen.routeName: (BuildContext context) => const ChatScreen(),
          Settings.routeName: (BuildContext context) => const Settings(),
          Profile.routeName: (BuildContext context) => const Profile(),
          Tutor.routeName: (BuildContext context) => const Tutor(),
          Team.routeName: (BuildContext context) => const Team(),
        },
      )
    )
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}