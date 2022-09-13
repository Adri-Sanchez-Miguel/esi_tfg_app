import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:esi_tfg_app/src/widgets/app_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PublicationDetail extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> publication;
  final User loggedInUser;
  const PublicationDetail({Key? key, required this.publication, required this.loggedInUser}) : super(key: key);

@override
  State<PublicationDetail> createState() => _PublicationDetailState();
}

class _PublicationDetailState extends State<PublicationDetail>{
  late TextEditingController _answerController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    _answerController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> likes = widget.publication['likes'];
    int numLikes = likes.length;
    return Scaffold(
      appBar: AppBar(title: const Text("Publicación")),
      body: GridView.count(
        primary: false,
        crossAxisCount: 1,
        crossAxisSpacing: 3,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(child:Text(widget.publication['title'], style: const TextStyle(fontSize: 35.0, fontWeight: FontWeight.w700, color: Color.fromARGB(255, 180, 50, 87)))),
                const SizedBox(height: 20.0,), 
                Text(widget.publication['description'], style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),),
                const Divider(thickness: 3.0, height: 30.0, color: Color.fromARGB(255, 180, 50, 87),),
                const Text("Usuario:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
                Text(widget.publication['user'], style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),),
                const SizedBox(height: 20.0,), 
                const Text("Conseguido el:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
                Text(widget.publication['creation_date'].toDate().toString(), style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),),
                const SizedBox(height: 15.0,),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.favorite, color: Color.fromARGB(255, 180, 50, 87),),
                      Text("$numLikes", style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
                
                    ],
                  ),
                // const SizedBox(height: 20.0,),
                const Divider(thickness: 3.0, height: 5.0, color: Color.fromARGB(255, 180, 50, 87),),
              ]
            )
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _getTextForm(),
                      _getButton(),
                    ],
                  ),
                const SizedBox(height: 20.0,),
                _getComments(),
              ]
            )
          ),
        ]
      )
    );
  }

  Widget _getTextForm(){
    return Form(
      key: _formkey,
      child: Expanded(
        child:Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey)
          ),
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          child: TextFormField(
            controller: _answerController,
            validator: ((value) => 
              value!.isEmpty ? "Rellene el comentario" : null),
            style: const TextStyle(fontSize: 20.0),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              hintText: "Comenta la publicación",
              labelText: "Comentario"
            ),
          ),
        ),
      ),
    );
  }

  Widget _getButton(){
    return Padding(
      padding:  const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          // Foreground color
          onPrimary: Theme.of(context).colorScheme.onPrimary,
          // Background color
          primary: const Color.fromARGB(255, 180, 50, 87),
        ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
        onPressed: () {
          if(_formkey.currentState!.validate()){
            setState(() {
              _addComment(_answerController.text);
            });
            _answerController.clear();
            _answerController.text = "";
          }
        },
        child: const Text("Comentar", style: TextStyle(fontSize: 17.0))
      ),
    );
  }
  
  void _addComment(String text) async {
    var publications = await FirestoreService().getOrderedMessage(field: "creation_date", collectionName: "publications");
    QueryDocumentSnapshot<Map<String, dynamic>>? actualPublication = publications.docs.firstWhere((element) => element.reference == widget.publication.reference);
    Map<String, dynamic> comments = actualPublication['comentarios'];
    String user = widget.loggedInUser.email!;
    comments.addAll({
      "$user/$text" : {user:text}
    });
    await FirestoreService().update(document: widget.publication.reference, collectionValues: {
      'comentarios': comments,
    });
  }

  void _deleteComment(String text) async{
    var publications = await FirestoreService().getOrderedMessage(field: "creation_date", collectionName: "publications");
    QueryDocumentSnapshot<Map<String, dynamic>>? actualPublication = publications.docs.firstWhere((element) => element.reference == widget.publication.reference);
    Map<String, dynamic> comments = actualPublication['comentarios'];
    String user = widget.loggedInUser.email!;
    
    comments.remove("$user/$text");
    await FirestoreService().update(document: widget.publication.reference, collectionValues: {
      'comentarios': comments,
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>>? _futurePublications() async{
    await Future.delayed(const Duration(milliseconds: 1500));
    return await FirestoreService().getOrderedMessage(field: "creation_date", collectionName: "publications");
  }

  Widget _getComments(){
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: _futurePublications(),
      builder: (context, snapshot){
        return snapshot.connectionState == ConnectionState.waiting ? 
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,    
          children:<Widget>[
            Container(
              padding: const EdgeInsets.only(top: 100.0),
              child: Center( 
                child: Platform.isAndroid ? 
                const CircularProgressIndicator() 
                : const CupertinoActivityIndicator()
              )
            )
          ]
        ) : snapshot.hasData ? Flexible(
          child: _getPublication(snapshot.data!.docs)
        ) : Container(height: 0.0,);
      },
    );
  }

  Widget _getPublication(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs){
    QueryDocumentSnapshot<Map<String, dynamic>>? newPublication = docs.firstWhere((element) => element.reference == widget.publication.reference);
    Map<String, dynamic> newComments = newPublication['comentarios'];
    Iterable<MapEntry<String, dynamic>> commentsIterable = newComments.entries;
    return ListView.builder(
      physics:  const AlwaysScrollableScrollPhysics(),
      addRepaintBoundaries: true,
      itemCount: newComments.length,
      itemBuilder: (context, index) =>
        _getItems(context, commentsIterable.elementAt(index)),
    );
  }

    Widget _getItems(BuildContext context, MapEntry<String, dynamic> comment){
    Map<String, dynamic> newComments = comment.value;
    Iterable<MapEntry<String, dynamic>> commentsIterable = newComments.entries;
    MapEntry<String, dynamic> finalComment = commentsIterable.first;
    String username = finalComment.key;
    String commentText = finalComment.value;
    Color background = Colors.white;
    Color decoration = Colors.black;

    return AppCard(
      trailing: widget.loggedInUser.email == username || widget.loggedInUser.email == widget.publication['user'] ?  PopupMenuButton(
        tooltip: "Delete the comment",
        icon: const Icon(Icons.more_vert_rounded),
        itemBuilder: (context) => <PopupMenuEntry<Widget>>[
          widget.loggedInUser.email == username || widget.loggedInUser.email == widget.publication['user'] ? 
            PopupMenuItem(child: const Center(child:Text("Borrar comentario")), onTap: (){
              setState(() {
                _deleteComment(commentText);
              });
            },) 
            : PopupMenuItem(child: Center(child:Container(height: 0.0,),), onTap: (){},),
        ],
      ) : IconButton(
        icon:  const Icon(Icons.more_vert_rounded),
        color:  Colors.white, 
        onPressed: () {},
      ),
      color: background,
      radius: 3.0,
      borderColor: Colors.black,
      iconColor: decoration,
      textColor: decoration,
      title: Text.rich(
        TextSpan(
          text: '', 
          children: <TextSpan>[
            TextSpan(text: 'Uusario: $username', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ],
        ),
      ),
      subtitle: Text('\nHa comentado: $commentText', style: const TextStyle(fontSize: 15.0)),
      onTap: (){}
    );
  }
}