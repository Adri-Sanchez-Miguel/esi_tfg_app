import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:esi_tfg_app/src/services/storage_service.dart';
import 'package:esi_tfg_app/src/widgets/app_card.dart';
import 'package:esi_tfg_app/src/widgets/app_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  final Storage storage = Storage();
  QuerySnapshot<Map<String, dynamic>>? _publications;
  QueryDocumentSnapshot<Map<String, dynamic>>? _refreshedPublication;
  File? imageFile;


  @override
  void initState() {
    super.initState();
    _refreshPublication();
    _answerController = TextEditingController();
  }

  void _refreshPublication() async {
    try{
    _publications = await FirestoreService().getOrderedMessage(field: "creation_date", collectionName: "publications");
    setState(() {
      _refreshedPublication = _publications!.docs.firstWhere((element) => element.reference == widget.publication.reference);
    });
    }catch(e){
      Fluttertoast.showToast(
        msg: e.toString(),
        fontSize: 20,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[400]
      );
    }
  }

  @override
  void dispose(){
    super.dispose();
    _answerController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if(_publications != null){
      List<String> splitDate = widget.publication['creation_date'].toDate().toString().split(' ');
      String date = splitDate.first;
      Map<String, dynamic> likes = _refreshedPublication!['likes'];
      int numLikes = likes.length;
      return Scaffold(
        appBar: AppBar(title: const Text("Publicación")),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(15.0),
            child: SizedBox(
              height: 1100.0,
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
                  const Text("Publicado el:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
                  Text(date, style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),),
                  const SizedBox(height: 15.0,),
                  const Center(child:Text("¡Pulsa para ver quién ha dado like!", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300))),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.favorite, color: Color.fromARGB(255, 211, 13, 69),),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 0,0,0),
                          textStyle: const TextStyle(fontSize: 25),
                        ),
                        onPressed: () {
                          _getModalSheet(context, likes);
                        },
                        child:Text("$numLikes", style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
                      ),
                    ],
                  ),
                  const Divider(thickness: 3.0, height: 5.0, color: Color.fromARGB(255, 180, 50, 87),),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                      child: _getPhoto(widget.publication["photo"]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _getTextForm(),
                              _getButton()
                            ],
                          ),
                        const SizedBox(height: 10.0,),
                      ]
                    )
                  ),
                  _getComments(),
                ]
              )
            ),
          )
        )
      );
    }else{
      return Scaffold(
        body:  Row(
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
        )
      ); 
    }
  }

  Future<dynamic> _getModalSheet(BuildContext context, Map<String, dynamic> likes){
    List <Widget> people = [];
    Iterable<dynamic> iterableLikes = likes.values;
    for(var person in iterableLikes){
      people.add(_getAppCard(person));
    }
    return showModalBottomSheet(
      context: context, 
      builder: (BuildContext context){
        return SizedBox(
          height: 600.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[ 
              const SizedBox(height: 20.0,),
              const Center(child:Text("Me gusta", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w700),),),
              const SizedBox(height: 20.0,),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child:Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 2.0)
                    ),
                    child:ListView.builder(
                      physics:  const AlwaysScrollableScrollPhysics(),
                      addRepaintBoundaries: true,
                      itemCount: people.length,
                      itemBuilder: (context, index) =>
                        people[index]
                    )
                  )
                )
              )
            ]
          )
        );
      }
    );
  }

  Widget _getAppCard(String person){
    Widget? icon = const Icon(Icons.person);
    Color colorDecoration = Colors.black;
    String title = person;

    return AppCard(
      active: false,
      color: Colors.white,
      radius: 3.0,
      borderColor: colorDecoration,
      textColor: Colors.black,
      leading: icon,
      title: Text.rich(
        TextSpan(
          text: '', 
          children: <TextSpan>[
            TextSpan(text: '$title\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
          ],
        ),
      ),
      onTap: (){}
    );
  }

  Widget _getTextForm(){
    return Form(
      key: _formkey,
      child: Flexible(
        child:Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey)
          ),
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          child: TextFormField(
            controller: _answerController,
            validator: ((value) {
              if(value!.isEmpty || value.length > 140) {
                return "El texto debe tener entre 1 y 140 caracteres";
              }else{return null;} 
            }),
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

  Widget _getPhoto(String name){
    try{
    if(name != ""){
      return FutureBuilder(
        future: storage.photoURL(name),
        builder: (context, AsyncSnapshot<String> snapshot){
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
          ) : snapshot.hasData ? Center(
              child:SizedBox (
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return DetailScreen(path: snapshot.data!, tag: 'publicationHero');
                    }));
                  },
                  child: Hero(
                    tag: 'publicationHero',
                    child: CachedNetworkImage(
                      key: ValueKey<String>(snapshot.data!),
                      imageUrl: snapshot.data!,
                      placeholder: (context, url) => Platform.isAndroid ? 
                        const CircularProgressIndicator() 
                        : const CupertinoActivityIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ),
              )
            )
          : Container(height: 0.0,);
        },
      );
    }else{
      return Container(height: 0.0, color: Colors.black38,);
    }
  }catch(e){
      Fluttertoast.showToast(
        msg: e.toString(),
        fontSize: 20,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[400]
      );
      return Container(height: 0.0,);
    }
  }

  Widget _getButton(){
    return Padding(
      padding:  const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onPrimary, 
          backgroundColor: const Color.fromARGB(255, 180, 50, 87),
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
        ) 
        : snapshot.hasData ? Flexible(
          child: _getPublication(snapshot.data!.docs)
        )
        : Container(height: 0.0,);
      },
    );
  }

  Widget _getPublication(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs){
    QueryDocumentSnapshot<Map<String, dynamic>>? newPublication = docs.firstWhere((element) => element.reference == widget.publication.reference);
    Map<String, dynamic> newComments = newPublication['comentarios'];
    Iterable<MapEntry<String, dynamic>> commentsIterable = newComments.entries;
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: ListView.builder(
        physics:  const AlwaysScrollableScrollPhysics(),
        addRepaintBoundaries: true,
        itemCount: newComments.length,
        itemBuilder: (context, index) =>
          _getItems(context, commentsIterable.elementAt(index)),
      )
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
      active: false,
      trailing: widget.loggedInUser.email == username || widget.loggedInUser.email == widget.publication['user'] ?  PopupMenuButton(
        tooltip: "Borra el comentario",
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
            TextSpan(text: 'Usuario: $username', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
          ],
        ),
      ),
      subtitle: Text('\nHa comentado: $commentText', style: const TextStyle(fontSize: 15.0)),
      onTap: (){}
    );
  }
}