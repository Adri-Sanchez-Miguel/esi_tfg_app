import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/models/contact_model.dart';
import 'package:esi_tfg_app/src/screens/contact_item.dart'; 

class Contact extends StatelessWidget {
  const Contact({Key? key}) : super(key: key);

  buildList(){
    return <ContactModel>[
      ContactModel(name: "Rodrigo", email: "rodrigo@gmail.com"),  
      ContactModel(name: "Raul", email: "raul@gmail.com"),    
      ContactModel(name: "Roman", email: "roman@gmail.com"),
      ContactModel(name: "Rodolfo", email: "rodolfo@gmail.com"),
      ContactModel(name: "Rosa", email: "rosa@gmail.com"),
      ContactModel(name: "Rocio", email: "rocio@gmail.com"),
      ContactModel(name: "Roberto", email: "roberto@gmail.com")
    ];
  }

  List<ContactItem> buildContactList(){
    return buildList()
    .map<ContactItem>((contact) => ContactItem(contact: contact,))
    .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children:  buildContactList(),
      ),
    );
  }
}