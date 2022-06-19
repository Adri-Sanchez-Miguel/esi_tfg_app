import 'dart:async';

class Validators{
  final validateEmail = StreamTransformer<String, String>
  .fromHandlers(
    handleData: (email, sink) {
      if(email.endsWith('@uclm.es') && email.contains('@',5) || email.endsWith('@alu.uclm.es') && email.contains('@',5)){
        sink.add(email);
      }else{
        sink.addError('Incluya un email universitario');
      }
    },
  );
  
  final validatePassword = StreamTransformer<String, String>
  .fromHandlers(
    handleData: (password, sink) {
      if(password.length > 7 && password.contains(RegExp(r'[a-z]')) && password.contains(RegExp(r'[A-Z]')) && password.contains(RegExp(r'[0-9]'))){
        sink.add(password);
      }else{
        sink.addError('Incluya 8 caracteres con mayúsculas, minúsculas y números');
      }
    },
  );
}