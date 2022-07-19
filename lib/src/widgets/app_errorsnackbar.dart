import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorSnackbar extends StatelessWidget {
  final String errorMessage;
  const ErrorSnackbar({Key? key, required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Platform.isAndroid ? AlertDialog(
        title: const Text('AlertDialog Title'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('This is a demo alert dialog.'),
              Text('Would you like to approve of this message?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ): 
      CupertinoAlertDialog(
        content: Container(
          padding: const EdgeInsets.all(16),
          height: 100,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 180, 50, 87),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 50,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text("¡Vaya!", style: TextStyle(fontSize: 18, color: Colors.white),),
                    Text(errorMessage, 
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          )
        ),
      )
    );
  }
}