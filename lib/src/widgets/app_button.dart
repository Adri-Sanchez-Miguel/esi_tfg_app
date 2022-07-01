import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Color color;
  final Color colorText;
  final Future<void> Function()? onPressed;
  final String name;
  
  const AppButton({Key? key, required this.color, required this.onPressed, required this.name, required this.colorText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        elevation: 5.0,
        child: SizedBox(
          height: 43.0,
          child: TextButton(
            onPressed: onPressed, 
            child: Text(name, style: TextStyle(color:colorText ),) 
          ),
        )
      ),
    );
  }
}