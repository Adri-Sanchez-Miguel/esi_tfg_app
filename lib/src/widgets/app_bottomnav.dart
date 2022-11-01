import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/challenge_screen.dart';
import 'package:esi_tfg_app/src/screens/new_challenge_screen.dart';
import 'package:esi_tfg_app/src/screens/new_message_screen.dart';
import 'package:esi_tfg_app/src/screens/reclamar_screen.dart';
import 'package:esi_tfg_app/src/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/screens/publication_screen.dart';

class BottomNav extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  
  const BottomNav({Key? key, required this.user}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions = <Widget>[
    PublicationsScreen(user: widget.user),
    ChallengeScreen(user: widget.user),
    const UsersScreen(),
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
            itemBuilder: (itemContext) => <PopupMenuEntry<Widget>>[
              PopupMenuItem(
                child: Center(
                  child:TextButton(
                    child: const Text("Nuevo mensaje", style: TextStyle(color: Colors.black87, fontSize: 17.0)), 
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NuevoMensaje(user: widget.user)));
                    },
                  )
                ), 
                onTap: (){},
              ),
              PopupMenuItem(
                child: Center(
                  child:TextButton(
                    child: const Text("Crear logro", style: TextStyle(color: Colors.black87, fontSize: 17.0), maxLines: 8,), 
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NuevoReto(user: widget.user)));
                    },
                  )
                ), 
                onTap: (){},
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: Center(
                  child:TextButton(
                    child: const Text("Reclamar logro", style: TextStyle(color: Colors.black87, fontSize: 17.0)), 
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ReclamarLogro(user: widget.user)));
                    },
                  )
                ), 
                onTap: (){},
              ),
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