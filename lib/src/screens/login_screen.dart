import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esi_tfg_app/src/bloc/bloc.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:esi_tfg_app/src/widgets/app_errormessage.dart';
import 'package:esi_tfg_app/src/widgets/app_texfield.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  String _email = "";
  String _password = "";
  late FocusNode _focusNode;
  bool _showSpinner = false; 
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String _errorMessage= "";
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
    _emailController.text = "";
    _passwordController.text = "";
    bloc.changeEmail;
    bloc.changePassword;
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset('images/menthor_logo.png'),
                const SizedBox(height: 30.0,),
                _emailField(bloc),
                const SizedBox(height: 15.0,),
                _passwordField(bloc),
                const SizedBox(height: 15.0,),
                _submitButton(bloc),
                _showErrorMessage(),
                const SizedBox(height: 10.0,),
                const Text("En caso de olvidar la contraseña, enviar un correo a: menthor.uclm@gmail.com",
                      textAlign: TextAlign.center,)
              ]
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
          hint: "Your email",
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
          hint: "Your password",
          label: "Password",
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
          color: snapshot.hasData && _emailController.text != "" && _passwordController.text != "" ? const Color.fromARGB(255, 180, 50, 87): Colors.black54,
          colorText: snapshot.hasData && _emailController.text != "" && _passwordController.text != "" ? Colors.white: Colors.white54,
          name: 'Sign in',
          onPressed: snapshot.hasData && _emailController.text != "" && _passwordController.text != "" ? ()async{
            _email = bloc.submitEmail();
            _password = bloc.submitPassword();
            try {
              setSpinnersStatus(true);
              var auth = await Authentiaction().loginUser(email: _email, password: _password);
              if (auth.success){
                Navigator.pushNamed(context, "/home");
                _emailController.text = "";
                _passwordController.text = "";
                bloc.changeEmail;
                bloc.changePassword;
                FocusScope.of(context).requestFocus(_focusNode);
              }else{
                setState(() {
                  _errorMessage = auth.errorMessage;
                }
                );
              }
              setSpinnersStatus(false);
            }
            catch(e){
              print(e);
            }
          } : null, 
        );
      }
    );
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