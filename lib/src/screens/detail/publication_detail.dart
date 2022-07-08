import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PublicationDetail extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> publication;
  const PublicationDetail({Key? key, required this.publication}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(publication['title'].toString())),
      body: Center(child: Text(publication['description'])),
    );
  }
}