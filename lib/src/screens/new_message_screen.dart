import 'package:flutter/material.dart';

enum Visibilidad { degree, team, mentor, mentorizado, profesor, all }

class NuevoMensaje extends StatefulWidget {
  static const String routeName = "/message"; 
  const NuevoMensaje({Key? key}) : super(key: key);

  @override
  State<NuevoMensaje> createState() => _NuevoMensajeState();
}

class _NuevoMensajeState extends State<NuevoMensaje> {
  late TextEditingController _titleController, _messageController;
  String _role = "";
  int _index = 0;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    _titleController.dispose();
    _messageController.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo mensaje"),
      ),
      body: GridView.count(
        primary: false,
        crossAxisCount: 1,
        mainAxisSpacing: 3.0,
        crossAxisSpacing: 3.0,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: SingleChildScrollView( 
              child: Form(
                key: _formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Center(
                      child: Text("Nuevo mensaje",
                        style: TextStyle(color: Color.fromARGB(255, 180, 50, 87), fontSize: 35.0, fontWeight: FontWeight.bold),),
                    ),
                    const SizedBox(height: 20.0,),
                    Form(
                      key: _formkey,
                      child: _getTextField(9, "Titula la publicación", "Título", _titleController),
                    ),
                    const SizedBox(height: 20.0,),
                    _getTextField(6, "Descripción de la publicación", "Descripción", _messageController),
                    // Un panel de opciones para elegir la visibilidad
                    const SizedBox(height: 10.0,),
                    const Text("Visibilidad:",
                      style: TextStyle(color: Color.fromARGB(255, 180, 50, 87), fontSize: 25.0, fontWeight: FontWeight.bold),
                    ),
                    _getRole(),
                    // Un botón para confirmar que se ha puesto la publicación
                    const SizedBox(height: 20.0,),
                  ]
                ),
              ),
            ),
          ),
        ]
      )
    );
  }

  Widget _getTextField(int maxLines, String hint, String label, TextEditingController controller){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey)
      ),
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextFormField(
        maxLines: maxLines,
        controller: controller,
        validator: ((value) => 
          value!.isEmpty ? "Rellene el campo" : null),
        style: const TextStyle(fontSize: 20.0),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
          hintText: hint,
          labelText: label
        ),
      ),
    );
  }

  Widget _getRole(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: Material(
        child: CircleAvatar(
          radius: 25.0,
          backgroundColor: const Color.fromRGBO(179, 0, 51, 1.0),
          child: PopupMenuButton<Visibilidad>(
            onSelected: (Visibilidad item) {
              setState(() {
                _role = item.name;
                _index = item.index;
              });
            },
            tooltip: "Visibilidad de la publicación",
            icon: Icon(Icons.adaptive.arrow_forward, color:Colors.white),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Visibilidad>>[
              const PopupMenuItem<Visibilidad>(
                value: Visibilidad.mentor,
                child: Text('Mentor'),
              ),
              const PopupMenuItem<Visibilidad>(
                value: Visibilidad.mentorizado,
                child: Text('Mentorizado'),
              ),
              const PopupMenuItem<Visibilidad>(
                value: Visibilidad.profesor,
                child: Text('Profesor'),
              ),
              const PopupMenuItem<Visibilidad>(
                value: Visibilidad.degree,
                child: Text('Mentor'),
              ),
              const PopupMenuItem<Visibilidad>(
                value: Visibilidad.team,
                child: Text('Mentorizado'),
              ),
              const PopupMenuItem<Visibilidad>(
                value: Visibilidad.all,
                child: Text('Todos'),
              ),
            ]
          )
        )
      ),
    );
  }
}