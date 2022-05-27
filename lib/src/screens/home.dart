import 'package:esi_tfg_app/src/screens/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/screens/login_screen.dart';

class Home extends StatelessWidget {

  Drawer getDrawer(BuildContext context){

    var header = DrawerHeader(child: Image.asset('assets/images/logo_esi_titulo.png',height: 120.0, width: 135.0,));
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
          Navigator.pushNamed(context, route);
        },
      );
    }

    ListTile getBack(Icon icon, String description){
      return ListTile(
        leading: icon,
        title: Text(description),
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context){
                return const MaterialApp(
                  title: "Iniciar Sesión",
                  home: Scaffold(
                    body: LoginScreen(),
                  ),
                );
              },
            ),
          );
        }
      );
    }

    ListView getList(){
      return ListView(
        children: <Widget>[
          header,
          getItem(const Icon(Icons.home), "Página Principal","/"),   
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
      ),
      drawer: Drawer(
        child: getDrawer(context),
      ),
      body: const BottomNav(),
    );
  }
}