import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/selectteam_screen.dart';
import 'package:esi_tfg_app/src/screens/detail/team_detail.dart';
import 'package:esi_tfg_app/src/screens/team_screen.dart';
import 'package:esi_tfg_app/src/screens/detail/user_detail.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/widgets/app_bottomnav.dart';

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
      var snap = await FirestoreService().getMessage(collectionName: "users");
      var teams = await FirestoreService().getMessage(collectionName: "teams");
      if (user != null && snap != null){
        setState(() {
          loggedInUser = user;
          _user = snap.docs.firstWhere((element) => element["email"] == user.email);
          Map<String, dynamic> teamsMap = _user!['team'];
          _teamsIterable = teamsMap.values;
          if(_user!['role']!= "profesor"){
            _team = teams.docs.firstWhere((element) => element.reference == teamsMap.values.first);
            _tutor = snap.docs.firstWhere((element) => element.reference == _team!['teacher']);
          }
        });
      }
    }catch(e){
      // Hacer llamada a método para mostrar error en pantalla
      print(e);
    }
  }
 // Cambiar tamaño grupo
  Drawer getDrawer(BuildContext context){
    var header = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DrawerHeader(child: 
          Image.asset('images/menthor_logo.png', scale: 0.8,),
        ), 
        Text(_user?["email"], style: const TextStyle(fontWeight: FontWeight.bold),)
      ]
    );
    var info = const AboutListTile(
      applicationVersion: "v0.1.0",
      icon: Icon(Icons.info),
      child: Text("Sobre la aplicación")
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
    if(_user?['degree'] != '' && _user != null){
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
  }
}