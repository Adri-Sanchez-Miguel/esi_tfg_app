import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:esi_tfg_app/src/widgets/app_container.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum Visibilidad {mentor, mentorizado, profesor, todos }
enum ROL {grado, todos }
enum Level {oro, plata, bronce, invalido}

class NuevoReto extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  static const String routeName = "/newchallenge"; 
  const NuevoReto({Key? key, this.user}) : super(key: key);

  @override
  State<NuevoReto> createState() => _NuevoRetoState();
}

  // AL GENERARLOS -> Simplemente introducimos el
  // string que queramos que sea su código qr y la
  // fecha de caducidad del reto, a parte de la 
  // visibilidad que tendrá el reto.
  // UCLMoney -> Puntos que te dan cuando consigues
  // retos.
  // AL RECLAMARLOS -> La idea es que los perfiles 
  // que a los que no vayan dirigido el reto puedan
  // verlo y así ayudar a los que no lo tengan a 
  // conseguirlo junto a los que estén en físico
  // ENVIAR QR a correo electrónico del que crea el reto
  // para que lo pueda imprimir (o guardar como imagen)
  // Poner un pequeño pause al recargar la eliminación de publicaciones
class _NuevoRetoState extends State<NuevoReto> {
  late TextEditingController _nameController, _descriptionController, _qrController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String _degreeString = "", _rolString = "", _showStringRol = "", _showStringDegree  = "", _showStringLevel  = "";
  int level = 0;
  bool _friendly = false;
  DateTime finalDate = DateTime.now().add(const Duration(days: 1));
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _qrController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _qrController.dispose();
    _descriptionController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo reto"),
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
              ContainTextField(maxLines: 2, hint: "Nombre del reto", label: "Nombre", controller: _nameController),
              const SizedBox(height: 20.0,),
              ContainTextField(maxLines: 5, hint: "Descripción del reto", label: "Descripción", controller: _descriptionController),
              const SizedBox(height: 20.0,),
              ContainTextField(maxLines: 5, hint: "Código QR", label: "Clave QR", controller: _qrController),
              const SizedBox(height: 20.0,), 
              _getFriendly(),           
              _getRow("¿A qué carrera pertenece el reto?", _showStringDegree, "degree"),
              _getRow("¿A quién hay que mostrar el reto?", _showStringRol, "rol"),
              Padding(padding: const EdgeInsets.symmetric(vertical: 5.0), 
                child:_getCoins()
              ),
              _showLevel('images/gold.png', "100 monedas"),
              _showLevel('images/silver.png', "20 monedas \n(Gratis profesores)"),
              _showLevel('images/bronze.png', "5 monedas (Gratis profesores\n y mentores)"),
              const SizedBox(height: 5.0),
              _getRow("¿Qué nivel tiene el reto?", _showStringLevel, "nivel"),
              const SizedBox(height: 20.0,),
              _getTextDate(),
              const SizedBox(height: 10.0,),
              _getDate(),
              _getButton(),
              const SizedBox(height: 10.0),
            ]
          ),
        ),
      ),
    );
  }

  Widget _getText(){
    return const Center(
      child: Text(
        "Crear reto",
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

  Widget _getFriendly(){
    return CheckboxListTile(
      title: const Text('Reto reclamable sin QR', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
      value: _friendly,
      onChanged: (bool? value) {
        setState(() {
          _friendly = !_friendly;
        });
      },
      secondary: const Icon(Icons.child_care),
    );
  }

  Widget _getCoins(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text("Monedas disponibles: ", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
        Text(widget.user!["coins"].toString(), style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
      ],
    );
  }

  Widget _showLevel(String photo, String message){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 25.0), 
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(photo, height: 40.0),
          Text(message, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),),
        ]
      )
    );
  }

  Widget _getFunction(String decider){
    switch (decider) {
      case "degree":
        return _getDegree();
      case "rol":
        return _getRole();
      default:
        return _getLevel();
    }
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
                _rolString = item.name;
                _showStringRol = item.name.toUpperCase();
              });
            },
            icon: Icon(Icons.adaptive.arrow_forward, color: Colors.white),
            itemBuilder: widget.user!["degree"] != "mentorizado" ?(BuildContext context){
              return <PopupMenuEntry<Visibilidad>>[
                _popUpMenuItem(Visibilidad.mentorizado, 'Mentorizados'),
                _popUpMenuItem(Visibilidad.mentor, 'Mentores'),
                _popUpMenuItem(Visibilidad.profesor, 'Profesores'),
                _popUpMenuItem(Visibilidad.todos, 'Todos')
              ];
            }:
            (BuildContext context){
              return <PopupMenuEntry<Visibilidad>>[
                _popUpMenuItem(Visibilidad.mentorizado, 'Mentorizados'),
                _popUpMenuItem(Visibilidad.todos, 'Todos')
              ];
            }
          )
        )
      ),
    );
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

  PopupMenuItem<Visibilidad> _popUpMenuItem(Visibilidad visibilidad, String text){
    return PopupMenuItem<Visibilidad>(
      value: visibilidad,
      child: Text(text),
    );
  }

  Widget _getLevel(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: Material(
        child: CircleAvatar(
          radius: 25.0,
          backgroundColor: const Color.fromRGBO(179, 0, 51, 1.0),
          child: PopupMenuButton<Level>(
            onSelected: (Level item) {
              if(item.name != "invalido"){
                setState(() {
                  switch(item.name){
                    case "bronce":
                      level = 1;
                      break;
                    case "plata":
                      level = 5;
                      break;
                    case "oro":
                      level = 20;
                      break;
                    default:
                      level = 0;
                      break;
                  }
                  _showStringLevel = item.name.toUpperCase();
                });
              }
            },
            icon: Icon(Icons.adaptive.arrow_forward, color: Colors.white),
            itemBuilder: (BuildContext context) => _getVisibility()
          )
        )
      ),
    );
  }

  List<PopupMenuEntry<Level>> _getVisibility(){
    return <PopupMenuEntry<Level>>[
      PopupMenuItem(
        value: widget.user!["coins"] > 100 ?  Level.oro : Level.invalido,
        child: widget.user!["coins"] > 100 ? 
          const Text('Oro')
          : const Text('Oro (Necesitas 100 monedas)', style: TextStyle(color: Colors.grey),)       
      ),
      PopupMenuItem(
        value: widget.user!["coins"] > 20 || widget.user!["role"] == "profesor" ? Level.plata : Level.invalido,
        child: widget.user!["coins"] > 20 || widget.user!["role"] == "profesor" ? 
          const Text('Plata')
          : const Text('Plata (Necesitas 20 monedas)', style: TextStyle(color: Colors.grey),)       
      ),
      PopupMenuItem(
        value: widget.user!["coins"] > 5 || widget.user!["role"] == "profesor" || widget.user!["role"] == "mentor" ? 
          Level.bronce : Level.invalido,
        child: widget.user!["coins"] > 5 || widget.user!["role"] == "profesor" || widget.user!["role"] == "mentor" ? 
          const Text('Bronce')
          : const Text('Bronce (Necesitas 5 monedas)', style: TextStyle(color: Colors.grey),)       
      ),
    ];
  }

  Widget _getTextDate(){
    return Center(
      child: Text(
        '${finalDate.day}/${finalDate.month}/${finalDate.year}',
        style: const TextStyle(fontSize: 20),
      )
    );
  }

  Widget _getDate(){
    return Padding(
      padding:const EdgeInsets.symmetric(horizontal: 30.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 180, 50, 87) ),
        onPressed: ()async{
          DateTime? newDate = await showDatePicker(
            context: context, 
            initialDate: finalDate, 
            firstDate: DateTime.now(), 
            lastDate: DateTime(2100)
          );
          if(newDate != null){
            setState(() {
              finalDate = newDate;
            });
          }
        }, 
        child: const Text("Selecciona la fecha límite del reto")
      )
    );
  }

  Widget _getButton(){
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AppButton(
        colorText: Colors.white,
        color:const Color.fromRGBO(179, 0, 51, 1.0),
        onPressed: _nameController.text != "" && _descriptionController.text != "" && _qrController.text != "" && level != 0 && _degreeString != "" && _rolString != "" ? ()async{
          _createChallenge(_nameController.text, _descriptionController.text, _qrController.text);
          _nameController.clear;
          _descriptionController.clear;
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pushNamed(context, "/home");
        } : ()async{ Fluttertoast.showToast(
          msg: "Introduzca nombre, descripción, grado, visibilidad y nivel del reto",
          fontSize: 20,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red[300]
        );},
        name: 'Crear reto',
      )
    );
  }

  void _createChallenge( String name, String description, String qr) async{
    // A los mentorizados le cuestan todos los logros
    // A los mentores le cuestan los logros de plata y oro
    // A los profesores le cuestan los logros de oro
    if((widget.user!["role"] != "profesor" && widget.user!["role"] != "mentor") 
      || (level != 1 && widget.user!["role"] == "mentor") 
      || (level == 20 && widget.user!["role"] == "profesor")){
      await FirestoreService().update(document: widget.user!.reference, collectionValues: {
        'coins': widget.user!["coins"]- (level*5),
      });
    }
    var snap = await FirestoreService().getMessage(collectionName: "challenges");
    if(!snap.docs.any((element) => element["qr_key"] == qr)){
      await FirestoreService().save(collectionName: "challenges", collectionValues: {
        'degree': _degreeString,
        'end_date': finalDate,
        'explanation': description,
        'friendly': _friendly,
        'level': level,
        'name': name,
        'qr_key': qr,
        'start_date': DateTime.now(),
        'users_visibility': _rolString
      }); 
    }
  }
}