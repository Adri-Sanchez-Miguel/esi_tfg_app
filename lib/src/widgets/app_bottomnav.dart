import 'package:esi_tfg_app/src/screens/challenge_screen.dart';
import 'package:esi_tfg_app/src/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/screens/publication_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    // Acordarse de que cuando se crea un reto se crea una publicación asociada
    // Ordenar publications por más recientes
    PublicationsScreen(),
    ChallengeScreen(),
    UsersScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: Material(
        color: const Color.fromRGBO(179, 0, 51, 1.0),
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        child: SizedBox(
          height: 60.0,
          width: 60.0,
          child: PopupMenuButton(
            icon: const Icon(Icons.add, color:Colors.white, size: 40.0,),
            itemBuilder: (context) => const [
              PopupMenuItem(child: Text("Nuevo mensaje")),
              PopupMenuItem(child: Text("Reclamar logro")),
              PopupMenuItem(child: Text("Crear logro")),
            ],
          )
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 180, 50, 87),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Muro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_rounded),
            label: 'Logros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Usuarios',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}