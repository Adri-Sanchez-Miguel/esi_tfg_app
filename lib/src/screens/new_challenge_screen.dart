import 'package:esi_tfg_app/src/widgets/app_container.dart';
import 'package:flutter/material.dart';

class NuevoReto extends StatefulWidget {
  static const String routeName = "/newchallenge"; 
  const NuevoReto({Key? key}) : super(key: key);

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
class _NuevoRetoState extends State<NuevoReto> {
  late TextEditingController _nameController, _descriptionController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
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
              const SizedBox(height: 30.0,),
              ContainTextField(maxLines: 5, hint: "Descripción del reto", label: "Descripción", controller: _descriptionController),
              // _getRow(),
              // _getButton(),
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
}