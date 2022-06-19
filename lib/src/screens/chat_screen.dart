import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/services/message_service.dart';
import 'package:esi_tfg_app/src/widgets/app_chatitems.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = '/chat';

  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late User loggedInUser;
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
    _getMessages();
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

  void _getMessages() async{
    //  final documents = await MessageService().getMessage("messages");
    //  for(var message in documents.docs){
    //    print(message);
    //  }
    await for(var snapshot in MessageService().getMessageStream("messages")){
      for(var message in snapshot.docs){
        print(message);
      }
    }
  }

  bool _isLoogedInUser(String sender){
    if(sender == loggedInUser.email){
      return true;
    }return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Chat screen"),
      //   actions: <Widget>[
      //     IconButton(
      //       onPressed: (){
      //         Authentiaction().signOut();
      //         Navigator.pop(context);
      //       }, 
      //       icon: const Icon(Icons.power_settings_new))
      //   ],
      // ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: MessageService().getMessageStream("messages"),
              builder: (context, snapshot){
                if(snapshot.hasData){
                  var messages = snapshot.data!.docs;
                  return Flexible(
                    child: ListView(
                      children: _getChatItems(messages),
                    )
                  );
                }
                return Container(
                  height: 0.0,
                );
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
                      MessageService().save(collectionName: "messages", collectionValues: {
                        'value': _messageController.text,
                        'sender': loggedInUser.email
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
    );
  }

  // Buscar perfiles(?)
  List<ChatItems> _getChatItems(dynamic messages){
    List<ChatItems> messageItems = [];
    for(var message in messages){
      final messageValue = message.get("value");
      final messageSender = message.get("sender");
      messageItems.add(ChatItems(
        sender: messageSender, 
        message: messageValue,
        isLoggedInUser: _isLoogedInUser(message.get("sender")),));
    }
    return messageItems;
  }
}