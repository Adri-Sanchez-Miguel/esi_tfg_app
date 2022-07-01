import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/selectteam_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _getEmail();
  }

  void _getEmail() async {
    try{
      var user = await Authentiaction().getRightUser();
      var snap = await FirestoreService().getMessage(collectionName: "users");
      if (user != null && snap != null){
        setState(() {
          loggedInUser = user;
          _user = snap.docs.firstWhere((element) => element["email"] == user.email);
        });
      }
    }catch(e){
      //Hacer llamada a método para mostrar error en pantalla
      print(e);
    }
  }
 
  Drawer getDrawer(BuildContext context){
    var header = DrawerHeader(child: 
          Image.asset('images/menthor_logo.png', scale: 0.8,),);
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
          getItem(const Icon(Icons.home), "Página Principal","/home"),   
          getItem(const Icon(Icons.settings), "Configuración", "/configuracion"),   
          getItem(const Icon(Icons.account_circle_rounded),"Perfil", "/perfil"),
          getItem(const Icon(Icons.group), "Equipo","/equipo"),   
          getItem(const Icon(Icons.school_rounded),"Tutor", "/tutor"),   
          info,
          getBack(const Icon(Icons.arrow_back_rounded),"Cerrar sesión")
        ],
      );
    }
    return Drawer(child: getList());
  }
  
  @override
  Widget build(BuildContext context) {
    if(_user?['degree'] != ''){
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