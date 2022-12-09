import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VerifyEmail extends StatefulWidget {
  static const String routeName = '/verification';

  const VerifyEmail({Key? key}) : super(key: key);
  
  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool canResendEmail = false;
  
  @override
  void initState(){
    super.initState();
    _getTrue();
  }

  void _getTrue() async{
    await Future.delayed(const Duration(seconds: 2));
    setState(() => canResendEmail = true);
  }

  Future sendVerificationEmail() async {
    try{
      await Authentication().sendVerificationEmail();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 60));
      setState(() => canResendEmail = true);

    }catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        fontSize: 20,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[400]
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Verificar email"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Center(
                child: Text("¡Bienvenido/a!",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 40.0, fontWeight: FontWeight.w700, color: Color.fromARGB(255, 180, 50, 87)))),
              const SizedBox(height: 20.0),
              const Center(
                child: Text("Haga click en el botón de enviar para mandar un correo a su cuenta que le permita cambiar la contraseña que se le ha asignado automáticamente.",
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
                )
              ),          
              const SizedBox(height: 10.0),
              const Center(
                child: Text("¡Importante!",
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w700,))),
              const SizedBox(height: 10.0),
              const Center(
                child: Text("Compruebe también la carpeta de spam de su correo, suele tardar en torno a un minuto en llegar.",
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10.0),
              const Center(
                child: Text("Para mayor seguridad la contraseña debe tener mínimo 8 caractéres, con al menos un número, una mayúscula y una minúscula, si no incluye estos parámetros, no podrá iniciar sesión y deberá cambiarla otra vez.",
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
                )
              ),
              const SizedBox(height: 30.0),
              AppButton(
                icon: Icons.email,
                color: canResendEmail ?  const Color.fromARGB(255, 180, 50, 87) : Colors.black54, 
                onPressed: canResendEmail ? ()async{
                  sendVerificationEmail();
                }: null, 
                name: "Enviar el correo", 
                colorText: canResendEmail ?  Colors.white : Colors.white54
              ),
              AppButton(
                key: const ValueKey('LogoutKey'),
                color: const Color.fromARGB(255, 180, 50, 87), 
                onPressed: ()async{
                  Authentication().signOut();
                  await Future.delayed(const Duration(milliseconds: 200)).then((value) {
                    Navigator.pop(context);
                  });
                }, 
                name: "Cerrar sesión", 
                colorText: Colors.white
              ),
            ]
          )
        )
      )
    );
  }
}
