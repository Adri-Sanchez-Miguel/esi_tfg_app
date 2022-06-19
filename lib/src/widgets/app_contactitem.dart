import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/model/contact_model.dart'; 

class ContactItem extends StatelessWidget {
  final ContactModel contact;
  const ContactItem({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(contact.name[0]),),
        title: Text(contact.name),
        subtitle: Text(contact.email),
    );
  }
}