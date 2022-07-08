import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String hint;
  final Function(String)? onChanged;
  final bool obscureText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final String label;
  final Widget? icon;
  final String? error;
  const AppTextField({Key? key, required this.hint, this.onChanged, required this.obscureText, this.focusNode, this.keyboardType, required this.label, required this.error, required this.controller, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      focusNode: focusNode,
      decoration: InputDecoration(
        icon: icon,
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        hintText: hint,
        labelText: label,
        errorText: error,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)) 
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)), 
          borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0)
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)), 
          borderSide: BorderSide(color: Colors.blueAccent, width: 2.0)
        ),
      ),
      onChanged: onChanged,
      textAlign: TextAlign.center,
      obscureText: obscureText,
    );
  }
}