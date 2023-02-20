import 'package:flutter/material.dart';

class ContainTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final int maxLines;
  const ContainTextField({Key? key, required this.maxLines, required this.hint, required this.label, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FocusNode focusNode = FocusNode();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey)),
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextFormField(
        focusNode: focusNode,
        maxLines: maxLines,
        controller: controller,
        validator: ((value) {
          if(value!.isEmpty || value.length > 140) {
            return "El texto debe tener entre 1 y 140 caracteres";
          }else{return null;} 
        }),
        style: const TextStyle(fontSize: 20.0),
        decoration: InputDecoration(
          contentPadding:
            const EdgeInsets.symmetric(horizontal: 5.0),
          hintText: hint,
          labelText: label
        ),
      ),
    );
  }
}