import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChallengeDetail extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> challenge;
  const ChallengeDetail({Key? key, required this.challenge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(challenge['name'].toString())),
      body: Center(child: Text(challenge['explanation'])),
    );
  }
}