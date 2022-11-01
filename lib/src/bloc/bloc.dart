import 'dart:async';
import 'package:esi_tfg_app/src/bloc/validators.dart';
import 'package:rxdart/rxdart.dart';

class Bloc with Validators{
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();

  //INFO: Validamos que el email y la contraseña cumplan las condiciones puestas en validators
  Stream<String> get email => _emailController.stream.transform(validateEmail);
  Stream<String> get password => _passwordController.stream.transform(validatePassword);
  Stream<bool> get submitValid => Rx.combineLatest2(email, password, (a, b) => true);

  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;

  String submitEmail(){
    return _emailController.value;
  }

  String submitPassword(){
    return _passwordController.value;
  }

  void resetEmail(){
    _emailController.value = "";
  }

  void resetPassword(){
    _passwordController.value = "";
  }

  // INFO: Para liberar recursos y memoria
  dispose(){
    _emailController.close();
    _passwordController.close();
  }
}