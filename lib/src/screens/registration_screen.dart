import 'package:esi_tfg_app/src/model/auth_request.dart';
import 'package:esi_tfg_app/src/screens/verification_email.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:esi_tfg_app/src/services/local_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:esi_tfg_app/src/bloc/bloc.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:esi_tfg_app/src/widgets/app_errormessage.dart';
import 'package:esi_tfg_app/src/widgets/app_texfield.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'dart:math';

enum Menu { mentor, mentorizado, profesor }

class RegistrationScreen extends StatefulWidget {
  static const String routeName = '/registration';
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>{
  String _role = "", _showString = "", _email = "";
  final String _errorMessage = "";
  late FocusNode _focusNode;
  Future<AuthenticationRequest>? auth;
  bool _showSpinner = false;   
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random.secure();
  late final LocalNotificationService service;

  @override
  void initState() {
    super.initState();
    service = LocalNotificationService();
    service.init();
    _focusNode = FocusNode();
    _emailController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    _focusNode.dispose();
    _emailController.dispose();
  }

  void setSpinnersStatus(bool status){
    setState(() {
      _showSpinner = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<Bloc>(context);
    bloc.changeEmail;
    
    return Scaffold(
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Flexible(child: Image.asset('images/menthor_logo.png')),
                  const SizedBox(height: 25.0,),
                  _emailField(bloc),
                  const SizedBox(height: 15.0,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('ROL: $_showString', style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),),
                      //_getStudentRole(),
                      _getRole(),
                      ]
                    ),
                  const SizedBox(height: 10.0,),
                  _submitButton(bloc),
                  _showErrorMessage()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailField(Bloc bloc){
    return StreamBuilder(
      stream: bloc.email,
      builder: (context, snapshot) {
        return AppTextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          focusNode: _focusNode,
          hint: "Tu email",
          label: "Email",
          error: snapshot.error as String?,
          onChanged: bloc.changeEmail,
          obscureText: false
        );
      }
    );    
  }

  Widget _submitButton(Bloc bloc){
    return StreamBuilder(
      stream: bloc.email,
      builder: (context, snapshot){
        return AppButton(
          color: snapshot.hasData && _emailController.text != "" && _role != "" ? const Color.fromRGBO(179, 0, 51, 1.0): Colors.black54,
          colorText: snapshot.hasData && _emailController.text != "" && _role != "" ? Colors.white: Colors.white54,
          name: 'Registrarse',
          onPressed: snapshot.hasData && _emailController.text != "" && _role != "" ? ()async{
            if(_emailController.text.endsWith('@alu.uclm.es') && _role == "profesor"){
              toast("Este correo no puede tener el rol de profesor, cambia tu rol para continuar.");
            }else if(_emailController.text.endsWith('@uclm.es') && _role == "mentorizado"){
              toast("Este correo no puede tener el rol de mentorizado, cambia tu rol para continuar.");
            }
            else{
              _email = bloc.submitEmail();
              try {
                setSpinnersStatus(true);
                auth= await Authentication().createUser(email: _email, password: _createPassword()).then((_){
                  _createUser(_emailController.text);
                  _createInitialPublication(_emailController.text);
                  _createNotification();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VerifyEmail()));
                  _emailController.text = "";
                  bloc.changeEmail;
                  FocusScope.of(context).requestFocus(_focusNode);
                  setSpinnersStatus(false);
                  return null;
                });
              }catch(e){
                toast(e.toString());
              }
            }
          } : null, 
        );
      }
    );
  }

  Widget _getRole(){
    return Material(
      color: const Color.fromRGBO(179, 0, 51, 1.0),
      borderRadius: BorderRadius.circular(30.0),
      elevation: 5.0,
      child: SizedBox(
        height: 50.0,
        width: 50.0,
        child: PopupMenuButton<Menu>(
          onSelected: (Menu item) {
            setState(() {
              _role = item.name;
              _showString = item.name.toUpperCase();
            });
          },
          icon: Icon(Icons.adaptive.arrow_forward, color:Colors.white),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Menu>>[
            const PopupMenuItem<Menu>(
              value: Menu.mentor,
              child: Text('Mentor'),
            ),
            const PopupMenuItem<Menu>(
              value: Menu.mentorizado,
              child: Text('Mentorizado'),
            ),
            const PopupMenuItem<Menu>(
              value: Menu.profesor,
              child: Text('Profesor'),
            ),
          ]
        )
      )
    );
  }

  void _createUser(String email) async{
    var snap = await FirestoreService().getMessage(collectionName: "challenges");
    var initialChallenge = snap.docs.firstWhere((element) => element.reference.toString() == "DocumentReference<Map<String, dynamic>>(challenges/6PAWfB7ZujBpZbdVyNeS)").reference;
    await FirestoreService().save(collectionName: "users", collectionValues: {
      'email': email.toLowerCase(),
      'role': _role,
      'image': '',
      'degree':'',
      'verified': false,
      'coins' : 1,
      'status': 1,
      'challenges_completed': {initialChallenge.path: initialChallenge},
      'sign_up_date': DateTime.now(),
      'team': {}
    }); 
  }

  void _createInitialPublication(String email) async{
    // INFO: Si la visibilidad es todos, decider es '', 
    // si es equipo, la referencia del equipo, esto es así para 
    // mostrar los mensajes del equipo del usuario en el muro
    var snap = await FirestoreService().getMessage(collectionName: "challenges");
    var challenge = snap.docs.firstWhere((element) => element.reference.toString() == "DocumentReference<Map<String, dynamic>>(challenges/6PAWfB7ZujBpZbdVyNeS)").reference;
    await FirestoreService().save(collectionName: "publications", collectionValues: {
      'challenge': challenge,
      'user': email.toLowerCase(),
      'visibility': 'todos',
      'decider': "",
      'title': '¡Hola mundo!',
      'creation_date': DateTime.now(),
      'comentarios': {},
      'degree': "todos",
      'likes': {},
      'photo': "",
      'description': 'Un nuevo usuario/a se ha unido al programa Menthor. ¡A por todas!'
    }); 
  }

  void _createNotification()async {
    await service.showNotification(id: 0, 
      title: "¡Bienvenido/a!", 
      body: "Recuerda que debes cambiar tu contraseña por otra que cumpla los requisitos de seguridad.");
  }

  Widget _showErrorMessage(){
    if(_errorMessage.isNotEmpty){
      return ErrorMessage(errorMessage: _errorMessage);
    }else{
      return Container(
        height: 0.0,
      );
    }
  }

  Future<bool?> toast(String message){
    return Fluttertoast.showToast(
      msg: message,
      fontSize: 20,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red[400]
    );
  }
  
  String _createPassword() {
    // Crear contraseña segura y random
    return String.fromCharCodes(Iterable.generate(16, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
}