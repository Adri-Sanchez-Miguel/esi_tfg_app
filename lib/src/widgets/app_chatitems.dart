import 'package:flutter/material.dart';

class ChatItems extends StatelessWidget {
  final String sender;
  final String message;
  final bool isLoggedInUser;
  const ChatItems({Key? key, required this.sender, required this.message, required this.isLoggedInUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(sender,
            style: const TextStyle(fontSize: 15.0, color: Colors.black54),
          ),
          Material(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0)
              ),
              elevation: 5.0,
            color: isLoggedInUser ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(message,
                style: isLoggedInUser ? const TextStyle(fontSize: 15.0, color: Colors.white) : const TextStyle(fontSize: 15.0, color: Colors.black),
              ),
            ),
          ),
        ],
      )
    );
  }
}