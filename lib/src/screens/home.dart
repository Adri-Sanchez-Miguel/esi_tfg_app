import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/selectdegree_screen.dart';
import 'package:esi_tfg_app/src/screens/selectteam_screen.dart';
import 'package:esi_tfg_app/src/screens/detail/team_detail.dart';
import 'package:esi_tfg_app/src/screens/settings_screen.dart';
import 'package:esi_tfg_app/src/screens/team_screen.dart';
import 'package:esi_tfg_app/src/screens/detail/user_detail.dart';
import 'package:esi_tfg_app/src/screens/welcome_screen.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/widgets/app_bottomnav.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  static const String routeName = "/home"; 
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? loggedInUser;
  QueryDocumentSnapshot<Map<String, dynamic>>? _user;
  QueryDocumentSnapshot<Map<String, dynamic>>? _team;
  QueryDocumentSnapshot<Map<String, dynamic>>? _tutor;

  @override
  void initState() {
    super.initState();
    _getEmail();
  }

  void _getEmail() async {
    try{
      await Future.delayed(const Duration(milliseconds: 2000));
      var user = await Authentication().getRightUser();
      var snap = await FirestoreService().getMessage(collectionName: "users");
      if (user != null){
        setState(() {
          loggedInUser = user;
          _user = snap.docs.firstWhere((element) => element["email"] == user.email);
        });
        if(!_user!["verified"]){
          await FirestoreService().update(document: _user!.reference, collectionValues: {
            'verified': true
          });  
          await Future.delayed(const Duration(milliseconds: 100)).then((_) {  
            Navigator.pushNamed(context, "/introduccion");
          });
        }
        var teams = await FirestoreService().getMessage(collectionName: "teams");
        setState(() {
          Map<String, dynamic> teamsMap = _user!['team'];
          if(teamsMap.isNotEmpty){
            if(_user!['role']!= "profesor"){
              _team = teams.docs.firstWhere((element) => element.reference == teamsMap.values.first);
              _tutor = snap.docs.firstWhere((element) => element.reference == _team!['teacher']);
            }
          }
        });
      }
    }catch(e){
      _toast(e.toString(), Colors.red[400]);
    }
  }
  Drawer getDrawer(BuildContext context){
    List<String>? split = _user?['email'].toString().split('@');
    String? email = split?.first;
    String? coins = _user?['coins'].toString();
    String? status =_user?['status'].toString();
    var header = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 180, 50, 87)
          ),
          child: Image.asset('images/menthor_logo_w.png'),
          ), 
        Padding(padding: const EdgeInsets.all(20.0),
          child: Text(email!, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text("Experiencia: $status px"),),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text("Monedas: $coins"),),
        const Divider()
      ]
    );
    var info = SafeArea(
      child: AboutListTile(
        applicationName: "Programa Menthor",
        applicationIcon: SizedBox(
          height: 75.0,
          child: Image.asset('images/menthor_icon.png',),
        ),
        applicationVersion: "Diciembre 2022",
        applicationLegalese: '\u{a9} Universidad de Castlla-La Mancha',
        aboutBoxChildren: <Widget>[
          const SizedBox(height: 5),
          RichText(
            text: const TextSpan(
              children: <TextSpan>[
                TextSpan(text: "Esta aplicación ha sido desarrollada en colaboración con "
                      'la Escuela Superior de Informática y la Faculta de Educación '
                      'dentro del programa de Mentoría Profesional. Más infromación en: ', 
                      style: TextStyle(color: Colors.black87)),
                TextSpan(
                  text: 'https://www.uclm.es', 
                    style: TextStyle(color: Colors.blue)),
              ],
            ),
          ),
          const SizedBox(height: 10.0,),
          ElevatedButton( 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
            child: const Text("Política de privacidad"),
            onPressed: () async {
              Uri url = Uri.parse("https://github.com/Adri-Sanchez-Miguel/Politica-de-privacidad/blob/main/POLITICA-DE-PRIVACIDAD.md");              
              var urllaunchable = await canLaunchUrl(url);
              if(urllaunchable){
                await launchUrl(url);
              }else{
                _toast("URL no accesible.", Colors.red[400]);
              }
            },
          ),
        ],
        icon: const Icon(Icons.info),
        child: const Text("Sobre la aplicación")
      ),
    );
    
    ListTile getItem(Icon icon, String description, String route){
      return ListTile(
        leading: icon,
        title: Text(description),
        onTap: (){          
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(user: _user)));
        },
      );
    }

    ListTile getTeam(Icon icon, String description){
      return ListTile(
        leading: icon,
        title: Text(description),
        onTap: (){          
          Navigator.pop(context);
          if(_user!['role']!= "profesor"){
            Navigator.push(context, MaterialPageRoute(builder: (context) => TeamDetail(team: _team)));
          }else{
            Navigator.push(context, MaterialPageRoute(builder: (context) => Team(user: _user)));
          }
        },
      );
    }

    ListTile getUser(Icon icon, String description, QueryDocumentSnapshot<Map<String, dynamic>>? user){
      return ListTile(
        leading: icon,
        title: Text(description),
        onTap: (){          
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetail(user: user)));
        },
      );
    }

    ListTile getBack(Icon icon, String description){
      return ListTile(
        leading: icon,
        title: Text(description),
        onTap: (){
          Authentication().signOut();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
        }
      );
    }

    ListView getList(){
      return ListView(
        children: <Widget>[
          header,
          getUser(const Icon(Icons.account_circle_rounded),"Perfil", _user),
          _user!['role']!= "profesor" ? getTeam(const Icon(Icons.group), "Equipo"): getTeam(const Icon(Icons.group), "Equipos"),
          _user!['role']!= "profesor" ? getUser(const Icon(Icons.school_rounded),"Tutor", _tutor) : Container(height: 0.0,),         
          info,
          getItem(const Icon(Icons.settings), "Configuración", "/configuracion"),   
          getBack(const Icon(Icons.arrow_back_rounded),"Cerrar sesión")
        ],
      );
    }
    return Drawer(child: getList());
  }
  
  @override
  Widget build(BuildContext context) {
    if(_user != null){
      if(_user!['degree'] != ''){
        Map<String, dynamic> team = _user!['team'];
        if(team.isNotEmpty){
          return Scaffold(
            appBar: AppBar(
              title: const Text("Muro"),
              backgroundColor: const Color.fromARGB(255, 180, 50, 87),
            ),
            drawer: Drawer(
              key: const ValueKey('drawer'),
              child: getDrawer(context),
            ),
            body: BottomNav(user: _user,),
          );
        }else{
          return SelectTeam(user: _user);
        }
      }else{
        return SelectDegree(user: _user);
      } 
    }else{
      return Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,    
          children:<Widget>[
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

  Future<bool?> _toast(String message, Color? color){
    return Fluttertoast.showToast(
      msg: message,
      fontSize: 20,
      gravity: ToastGravity.CENTER,
      backgroundColor: color
    );
  }
}