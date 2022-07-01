import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/screens/chat_screen.dart';
import 'package:esi_tfg_app/src/services/contact.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 151, 215));
  static const List<Widget> _widgetOptions = <Widget>[
    // Acordarse de que cuando se crea un reto se crea una publicación asociada
    // Ordenar publications por más recientes
    Contact(),
    ChatScreen(),
    Text(
      'Index 2: Usuarios',
      style: optionStyle,
    )
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
            icon: Icon(Icons.new_label),
            label: 'Crear',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}