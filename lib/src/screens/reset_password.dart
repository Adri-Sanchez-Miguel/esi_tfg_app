import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:esi_tfg_app/src/widgets/app_texfield.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NewPassword extends StatefulWidget {
  static const String routeName = '/password';

  const NewPassword({Key? key}) : super(key: key);
  
  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  bool canResendEmail = true;
  late TextEditingController _emailController;

  
  @override
  void initState(){
    super.initState();
    _emailController = TextEditingController();
  }

    @override
  void dispose(){
    super.dispose();
    _emailController.dispose();
  }

  Future resetEmail() async {
    try{
      QuerySnapshot<Map<String, dynamic>> users = await FirestoreService().getMessage(collectionName: "users");
      if(validateEmail(users, _emailController.text.toLowerCase())){
        await Authentication().resetEmail(_emailController.text);
        _emailController.clear;

        setState(() => canResendEmail = false);
        await Future.delayed(const Duration(seconds: 60));
        setState(() => canResendEmail = true);
      }else{
        toast("Email no encontrado en la base de datos");
      }
    }catch (e) {
      toast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nueva contraseña"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text("Correo: ",
                  style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w700, color: Color.fromARGB(255, 180, 50, 87)),
              ),
              const SizedBox(height: 30.0),
              _emailField(),
              const SizedBox(height: 20.0),
              AppButton(
                icon: Icons.email,
                color: canResendEmail ?  const Color.fromARGB(255, 180, 50, 87) : Colors.black54, 
                onPressed: canResendEmail ? ()async{
                  resetEmail();
                }: null, 
                name: "Enviar el correo", 
                colorText: canResendEmail ?  Colors.white : Colors.white54
              ),
              const SizedBox(height: 20.0),
              const Center(
                child: Text("Para mayor seguridad la contraseña debe tener mínimo 8 caractéres, con al menos un número, una mayúscula y una minúscula, si no incluye estos parámetros, no podrá iniciar sesión y deberá cambiarla otra vez.",
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
                )
              ),
            ]
          )
        )
      )
    );
  }

  Widget _emailField(){
    return AppTextField(
      error: "",
      icon: const Icon(Icons.search),
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      hint: "Email",
      label: "Buscar usuario",
      obscureText: false
    ); 
  }

  Future<bool?> toast(String message){
    return Fluttertoast.showToast(
      msg: message,
      fontSize: 20,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red[400]
    );
  }
  
  bool validateEmail(QuerySnapshot<Map<String, dynamic>> users, String email) {
    if(users.docs.any((element) => element["email"] == email)){
      return true;
    }else{
      return false;
    }
  }
}
