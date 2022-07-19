import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:esi_tfg_app/src/bloc/bloc.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:esi_tfg_app/src/widgets/app_errormessage.dart';
import 'package:esi_tfg_app/src/widgets/app_texfield.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

enum Menu { mentor, mentorizado, profesor }

class RegistrationScreen extends StatefulWidget {
  static const String routeName = '/registration';
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>{
  String _role = "", _email = "", _password = "", _errorMessage = "";
  late FocusNode _focusNode;
  bool _showSpinner = false;   
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    _focusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
    bloc.changePassword;
    
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
                  _passwordField(bloc),
                  const SizedBox(height: 15.0,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('ROL: $_role', style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),),
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

  Widget _passwordField(Bloc bloc){
    return StreamBuilder(
      stream: bloc.password,
      builder: (context, snapshot) {
        return AppTextField(
          controller: _passwordController,
          hint: "Tu contraseña",
          label: "Contraseña",
          error: snapshot.error as String?,
          onChanged: bloc.changePassword,
          obscureText: true,
        );
      }
    );
  }

  Widget _submitButton(Bloc bloc){
    return StreamBuilder(
      stream: bloc.submitValid,
      builder: (context, snapshot){
        return AppButton(
          color: snapshot.hasData && _emailController.text != "" && _passwordController.text != "" && _role != "" ? const Color.fromRGBO(179, 0, 51, 1.0): Colors.black54,
          colorText: snapshot.hasData && _emailController.text != "" && _passwordController.text != "" && _role != "" ? Colors.white: Colors.white54,
          name: 'Registrarse',
          onPressed: snapshot.hasData && _emailController.text != "" && _passwordController.text != "" && _role != "" ? ()async{
            _email = bloc.submitEmail();
            _password = bloc.submitPassword();
            try {
              setSpinnersStatus(true);
              var auth= await Authentiaction().createUser(email: _email, password: _password);
              if(auth.success){
                _createUser(_emailController.text);
                _createInitialPublication(_emailController.text);
                Navigator.pushNamed(context, "/selectdegree");
                _emailController.text = "";
                _passwordController.text = "";
                bloc.changeEmail;
                bloc.changePassword;
                FocusScope.of(context).requestFocus(_focusNode);
              }else{
                _errorMessage = auth.errorMessage;
              }
              setSpinnersStatus(false);
            }catch(e){
              Fluttertoast.showToast(
                msg: e.toString(),
                fontSize: 20,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.red[400]
              );
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
      'email': email,
      'role': _role,
      'image': '',
      'degree':'',
      'status': 0,
      'challenges_completed': {"1": initialChallenge},
      'sign_up_date': DateTime.now(),
      'team': {}
    }); 
  }

  void _createInitialPublication(String email) async{
    var snap = await FirestoreService().getMessage(collectionName: "challenges");
    var challenge = snap.docs.firstWhere((element) => element.reference.toString() == "DocumentReference<Map<String, dynamic>>(challenges/6PAWfB7ZujBpZbdVyNeS)").reference;
    await FirestoreService().save(collectionName: "publications", collectionValues: {
      'challenge': challenge,
      'user': email,
      'visibility': 'all',
      'decider': null,
      'title': '¡Hola mundo!',
      'creation_date': DateTime.now(),
      'comentarios': {},
      'likes': {},
      'description': 'Un nuevo usuario/a se ha unido al programa Menthor. ¡A por todas!'
    }); 
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
}