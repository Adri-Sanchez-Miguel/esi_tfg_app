import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:esi_tfg_app/src/widgets/app_chatitems.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = '/chat';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late User loggedInUser;
  bool _showSpinner = false; 
  final TextEditingController _messageController = TextEditingController();

  final InputDecoration _messageTextFieldDecoration = const InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    hintText:  "Ingrese su mensaje aquí...........",
    border: InputBorder.none
  );

  final BoxDecoration _messageContainerDecoration = const BoxDecoration(
    border: Border(top: BorderSide(color: Colors.lightBlueAccent, width: 2.0))
  );

  final TextStyle _sendButtonStyle = const TextStyle(
    color: Colors.white,
    fontSize: 18.0
  );

  @override
  void initState() {
    super.initState();
    _getRightUser();
  }

  void _getRightUser() async {
    try{
    var user = await Authentiaction().getRightUser();
    if (user != null){
      loggedInUser = user;
    }
    }catch(e){
      //Hacer llamada a método para mostrar error en pantalla
      print(e);
    }
  }

  // void _getMessages() async{
  //   final documents = await MessageService().getMessage("messages");
  //   for(var message in documents.docs){
  //    print(message);
  //   }
  //   await for(var snapshot in FirestoreService().getMessageStream("messages")){
  //     for(var message in snapshot.docs){
  //       print(message);
  //     }
  //   }
  // }

  bool _isLoogedInUser(String sender){
    if(sender == loggedInUser.email){
      return true;
    }return false;
  }

  void setSpinnersStatus(bool status){
    setState(() {
      _showSpinner = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: FirestoreService().getMessage(collectionName: "publications"),
                builder: (context, snapshot){
                  if(snapshot.hasData){
                    var messages = snapshot.data!.docs;
                    return Flexible(
                      child: ListView(
                        children: _getChatItems(messages),
                      )
                    );
                  }else{
                    return Container(
                      height: 0.0,
                    );
                  }
                },
              ),
              Container(
                decoration:  _messageContainerDecoration,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        decoration: _messageTextFieldDecoration,
                        controller: _messageController,
                      )
                    ),
                    ElevatedButton(
                      onPressed: (){
                        FirestoreService().save(collectionName: "publication", collectionValues: {
                          'title': _messageController.text,
                          'description': loggedInUser.email
                        });
                        _messageController.clear;
                      },
                      child: Text("Enviar", style: _sendButtonStyle,)
                    ),
                  ],
                )
              )
            ],
          ),
        ),
      )
    );
  }

  // Buscar perfiles(?)
  List<ChatItems> _getChatItems(dynamic messages){
    List<ChatItems> messageItems = [];
    for(var message in messages){
      final messageValue = message.get("title");
      final messageSender = message.get("description");
      messageItems.add(ChatItems(
        sender: messageSender, 
        message: messageValue,
        isLoggedInUser: _isLoogedInUser(message.get("title")),));
    }
    return messageItems;
  }
}