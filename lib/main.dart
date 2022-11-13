import 'package:esi_tfg_app/src/screens/reset_password.dart';
import 'package:esi_tfg_app/src/screens/selectdegree_screen.dart';
import 'package:esi_tfg_app/src/screens/selectteam_screen.dart';
import 'package:esi_tfg_app/src/screens/verification_email.dart';
import 'package:esi_tfg_app/src/widgets/app_introduction.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/bloc/bloc.dart';
import 'package:esi_tfg_app/src/screens/publication_screen.dart';
import 'package:esi_tfg_app/src/screens/home.dart';
import 'package:esi_tfg_app/src/screens/login_screen.dart';
import 'package:esi_tfg_app/src/screens/reclamar_screen.dart';
import 'package:esi_tfg_app/src/screens/registration_screen.dart';
import 'package:esi_tfg_app/src/screens/settings_screen.dart';
import 'package:esi_tfg_app/src/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  try{
    WidgetsFlutterBinding.ensureInitialized();
  
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) => 
    runApp(
      Provider(
        create: (context) => Bloc(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
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
            VerifyEmail.routeName:  (BuildContext context) => const VerifyEmail(),
            Home.routeName:  (BuildContext context) => const Home(),
            PublicationsScreen.routeName: (BuildContext context) => const PublicationsScreen(),
            SettingsScreen.routeName: (BuildContext context) => const SettingsScreen(),
            ReclamarLogro.routeName: (BuildContext context) => const ReclamarLogro(),
            NewPassword.routeName: (BuildContext context) => const NewPassword(),
            IntroductionPages.routeName: (BuildContext context) => const IntroductionPages(),
          },
        )
      )
    )
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  }catch(e){
    Fluttertoast.showToast(
      msg: "Error inicializando Firebsase",
      fontSize: 20,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red[400]
    );
  }
}