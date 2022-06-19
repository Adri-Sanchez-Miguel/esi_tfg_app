import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/widgets/app_bottomnav.dart';

class Home extends StatefulWidget {
  static const String routeName = "/home"; 
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
  }
}