import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/selectdegree_screen.dart';
import 'package:esi_tfg_app/src/screens/selectteam_screen.dart';
import 'package:esi_tfg_app/src/screens/detail/team_detail.dart';
import 'package:esi_tfg_app/src/screens/team_screen.dart';
import 'package:esi_tfg_app/src/screens/detail/user_detail.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/widgets/app_bottomnav.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  Iterable<dynamic>? _teamsIterable;

  @override
  void initState() {
    super.initState();
    _getEmail();
  }

  void _getEmail() async {
    try{
      var user = await Authentiaction().getRightUser();
      await Future.delayed(const Duration(milliseconds: 1500));
      var snap = await FirestoreService().getMessage(collectionName: "users");
      if (user != null && snap != null){
        setState(() {
          loggedInUser = user;
          _user = snap.docs.firstWhere((element) => element["email"] == user.email);
        });
        var teams = await FirestoreService().getMessage(collectionName: "teams");
        setState(() {
          Map<String, dynamic> teamsMap = _user!['team'];
          if(teamsMap.isNotEmpty){
            _teamsIterable = teamsMap.values;
            if(_user!['role']!= "profesor"){
              _team = teams.docs.firstWhere((element) => element.reference == teamsMap.values.first);
              _tutor = snap.docs.firstWhere((element) => element.reference == _team!['teacher']);
            }
          }
        });
      }
    }catch(e){
      Fluttertoast.showToast(
        msg: e.toString(),
        fontSize: 20,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[400]
      );
    }
  }
 // Cambiar tamaño grupo
  Drawer getDrawer(BuildContext context){
    var header = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DrawerHeader(
          child: Image.asset('images/menthor_logo.png', scale: 0.8,),
          ), 
        Padding(padding: const EdgeInsets.all(20.0),
        child: Text(_user?["email"], style: const TextStyle(fontSize: 20.0),)),
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
        applicationVersion: "Septiembre 2022",
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
          Navigator.pushNamed(context, route);
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
          Authentiaction().signOut();
          Navigator.pop(context);
          Navigator.pop(context);
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
              child: getDrawer(context),
            ),
            body: const BottomNav(),
          );
        }else{
          return const SelectTeam();
        }
      }else{
        return const SelectDegree();
      }
    }else{
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch, 
          children: <Widget>[
            Center(
               child: AnimatedTextKit(animatedTexts: [
                RotateAnimatedText("¡Hola de nuevo!", 
                duration: const Duration(milliseconds:  900),
                textStyle: const TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold), 
                textAlign: TextAlign.start,
                )
              ])
            )
          ]
        )
      );
    }
  }
}