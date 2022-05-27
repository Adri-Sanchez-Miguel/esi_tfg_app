class ValidationMixins{

  String? validateEmail(String? value){
    if(!value!.contains('@')){
      return " invalid";
    }
    return null;
  }

    String? validatePassword(String? value){
    if(value!.length < 6){
      return " invalid";
    }
    return null;
  }
}