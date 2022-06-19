import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String errorMessage;
  const ErrorMessage({Key? key, required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child:Text(
        errorMessage,
        style: const TextStyle(
          fontSize: 17.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300
        ),
      )
    );
  }
}