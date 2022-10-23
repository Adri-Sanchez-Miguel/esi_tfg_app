import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/services/storage_service.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:esi_tfg_app/src/widgets/app_container.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

enum Visibilidad {mentor, mentorizado, profesor, equipo, todos }
enum ROL {grado, todos }

class NuevoMensaje extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  static const String routeName = "/message";
  const NuevoMensaje({Key? key, required this.user}) : super(key: key);

  @override
  State<NuevoMensaje> createState() => _NuevoMensajeState();
}

// Mentorizados: habilitado para tutores y mentores, pero no para mentorizados
// Mentores: limitar también 
// Cambiar números por letras
// Cuidado con los tiempos de borrado
// Borrar publicación para profesores y permitir borrar usuarios (sin eliminar publicaciones)
// Poner fotos tanto para reclamar retos como en los mensajes.
// Cambiar Retos completados en el perfil por el 
// número de retos conseguidos.
// Botón inhabilitar cuenta
// Poner error usuario habilitado
// Eliminar foto de Storage cuando se elimina la publicación
// Poner botón por si se quiere otra foto
// Poner opción para poner qr manualmente con el código
// Para los logros disponibles que son para todos, foto o mensaje obligatorio
// Poner imagen chiquitita (o icono) en el muro
// Incorrect use of ParentDataWidget
class _NuevoMensajeState extends State<NuevoMensaje> {
  late TextEditingController _titleController, _messageController;
  String _role = "", _decider="", _degreeString = "",_showStringRol = "", _showStringDegree  = "", _imageName = "";
  
  File? imageFile;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final Storage storage = Storage();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
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
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 30.0),
              _getText(),
              const SizedBox(height: 30.0),
              ContainTextField(maxLines: 2, hint: "Titula la publicación", label: "Título", controller: _titleController),
              const SizedBox(height: 30.0,),
              ContainTextField(maxLines: 7, hint: "Mensaje de la publicación", label: "Mensaje", controller: _messageController),
              const SizedBox(height: 10.0),
              imageFile == null ? 
                Padding(
                  padding:const EdgeInsets.only(left: 100.0, right: 100.0),
                  child: AppButton(icon: Icons.photo, color: const Color.fromARGB(255, 180, 50, 87), onPressed: ()async{_seleccionGaleria();}, name: "Selecciona una foto", colorText: Colors.white)) 
                :Padding(
                  padding:const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                  child: Image.file(
                    imageFile!,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 10.0),
              imageFile == null ?  
                Padding(
                  padding:const EdgeInsets.only(left: 100.0, right: 100.0),
                  child: AppButton(icon: Icons.camera_alt, color: const Color.fromARGB(255, 180, 50, 87), onPressed: ()async{ _hazFoto();}, name: "Haz una foto", colorText: Colors.white)) 
                :Padding(
                  padding:const EdgeInsets.only(left: 100.0, right: 100.0),
                  child: AppButton(
                    icon: Icons.photo,
                    color: const Color.fromARGB(255, 180, 50, 87), 
                    onPressed: ()async{ setState(() {
                      imageFile = null;
                    });}, name: "Seleccionar otra", 
                    colorText: Colors.white
                  )
                ),
              _getRow("¿A qué carrera mostrar el mensaje?", _showStringDegree, "degree"),
              _getRow("¿A quién hay que mostrar la publicación?", _showStringRol, "rol"),
              _getButton(),
            ]
          ),
        ),
      ),
    );
  }

  Widget _getText(){
    return const Center(
      child: Text(
        "Nuevo mensaje",
        style: TextStyle(
          color: Color.fromARGB(255, 180, 50, 87),
          fontSize: 50.0,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget _getRow(String description, String selectedString, String method){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color.fromARGB(255, 180, 50, 87))),
      child: Padding(
        padding:const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,    
          children:<Widget>[
            Text(description,
              style: const TextStyle(
                color: Color.fromARGB(255, 180, 50, 87),
                fontSize: 25.0,
                fontWeight: FontWeight.bold
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                selectedString, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),    
            _getFunction(method),
          ],
        )
      )
    );
  }

  Widget _getFunction(String decider){
    switch (decider) {
      case "degree":
        return _getDegree();
      default:
        return _getRole();
    }
  }

  Widget _getDegree() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: Material(
        child: CircleAvatar(
          radius: 25.0,
          backgroundColor: const Color.fromRGBO(179, 0, 51, 1.0),
          child: PopupMenuButton<ROL>(
            onSelected: (ROL item) {
              setState(() {
                _showStringDegree = item.name.toUpperCase();
                if(item.name == "grado"){
                  _degreeString = widget.user!["degree"];
                }
                else{
                  _degreeString = "todos";
                }
              });
            },
            icon: Icon(Icons.adaptive.arrow_forward, color: Colors.white),
            itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<ROL>>[
                const PopupMenuItem(
                  value: ROL.grado,
                  child: Text('Mi grado'),
                ),
                const PopupMenuItem(
                  value: ROL.todos,
                  child: Text('Todos los grados'),
                ),
              ]
          )
        )
      ),
    );
  }

  Widget _getRole() {
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
                _showStringRol = item.name.toUpperCase();
                if(item.name == "degree"){
                  _decider = widget.user!["degree"];
                }
                if(item.name == "team"){
                  _decider = widget.user!["team"];
                }
              });
            },
            tooltip: "Visibilidad de la publicación",
            icon: Icon(Icons.adaptive.arrow_forward, color: Colors.white),
            itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<Visibilidad>>[
                _popUpMenuItem(Visibilidad.mentor, '1: Mentores'),
                _popUpMenuItem(Visibilidad.mentorizado, '2: Mentorizados'),
                _popUpMenuItem(Visibilidad.profesor, '3: Mi tutor'),
                _popUpMenuItem(Visibilidad.equipo, '4: Mi equipo'),
                _popUpMenuItem(Visibilidad.todos, '5: Todos')
              ]
          )
        )
      ),
    );
  }

  PopupMenuItem<Visibilidad> _popUpMenuItem(Visibilidad visibilidad, String text){
    return PopupMenuItem<Visibilidad>(
      value: visibilidad,
      child: Text(text),
    );
  }

  Widget _getButton(){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AppButton(
        colorText: Colors.white,
        color:const Color.fromRGBO(179, 0, 51, 1.0),
        onPressed: _titleController.text != "" && _messageController.text != "" && _showStringDegree != "" && _showStringRol != "" ? ()async{
          _createPublication(widget.user!["email"], _titleController.text, _messageController.text);
          if(imageFile != null){
            _savePhoto();
          }
          _titleController.clear;
          _messageController.clear;
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pushNamed(context, "/home");
        } : ()async{ Fluttertoast.showToast(
          msg: "Introduzca título, descripción y visibilidad",
          fontSize: 20,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red[300]
        );},
        name: 'Crear publicación',
      )
    );
  }

  void _createPublication(String email, String title, String description) async{
    await FirestoreService().save(collectionName: "publications", collectionValues: {
      'challenge': null,
      'user': email,
      'visibility': _role,
      'decider': _decider,
      'title': title,
      'degree' : _degreeString,
      'creation_date': DateTime.now(),
      'comentarios': {},
      'likes': {},
      'description': description,
      'photo': _imageName
    }); 
  }

  void _savePhoto() async{
    storage.uploadFile(imageFile, _imageName);
  }

  void _seleccionGaleria() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        _imageName = pickedFile.name;
      });
    }
  }

  /// Get from Camera
  void _hazFoto() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        _imageName = pickedFile.name;
      });
    }
  }
}