import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/detail/publication_detail.dart';
import 'package:esi_tfg_app/src/services/storage_service.dart';
import 'package:esi_tfg_app/src/widgets/app_card.dart';
import 'package:esi_tfg_app/src/widgets/app_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/services/authentication.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class PublicationsScreen extends StatefulWidget {
  static const String routeName = '/publications';
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  
  const PublicationsScreen({Key? key, this.user}) : super(key: key);

  @override
  State<PublicationsScreen> createState() => _PublicationsScreenState();
}

class _PublicationsScreenState extends State<PublicationsScreen> {
  late User loggedInUser;
  QuerySnapshot<Map<String, dynamic>>? _users;
  bool _showSpinner = false; 
  final Storage storage = Storage();

  @override
  void initState() {
    super.initState();
    _getRightUser();
  }

  void _getRightUser() async {
    try{
    var user = await Authentication().getRightUser();
    _users = await FirestoreService().getMessage(collectionName: "users");
    if (user != null){
      setState(() {
        loggedInUser = user;
      });
    }
    }catch(e){
      Fluttertoast.showToast(
        msg: e.toString(),
        fontSize: 20,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[400]
      );
    }
  }

  void setSpinnersStatus(bool status){
    setState(() {
      _showSpinner = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_users!= null){
      return Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: _showSpinner,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                _getPublications(),
              ],
            ),
          ),
        )
      );
    }else{
      return const Text("Cargando...");
    }
  }

  Widget _getPublications(){
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
          child: RefreshIndicator(
            onRefresh: () async{
              setState((){
                _getPublications();
              });
            },
            child: ListView.builder(
              physics:  const AlwaysScrollableScrollPhysics(),
              addRepaintBoundaries: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) =>
                _getItems(context, snapshot.data!.docs[index]),
            )
          )
        )
        : Container(height: 0.0,);
      },
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>>? _futurePublications() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    return await FirestoreService().getOrderedMessage(field: "creation_date", collectionName: "publications");
  }

  Widget _getItems(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> publication){
    var user = _users!.docs.firstWhere((element) => element["email"] == loggedInUser.email);
    var publicationUser = _users!.docs.firstWhere((element) => element["email"] == publication["user"]);
    Widget? icon = const Icon(Icons.group);
    if(publicationUser["image"] != ""){
      icon = _getPhoto(publicationUser["image"], 300.0);
    }else{
      icon = const Icon(Icons.group);
    }
    if( publication["degree"] != "todos" && publication["degree"] != user['degree']){
      return Container(
        height: 0.0,
      );
    }
    switch(publication['visibility']){
      case 'team':
        if(publication['decider'] == user['team']){
          return _getAppCard(icon, publication, Colors.teal);
        }else{
          return Container(
            height: 0.0,
          );
        }
      case 'mentor':
        if(user['role'] == "mentor"){
          return _getAppCard(icon, publication, Colors.indigo);
        }else{
          return Container(
            height: 0.0,
          );
        }
      case 'profesor':
        if(user['role'] == "profesor"){
          return _getAppCard(icon, publication, Colors.indigo);
        }else{
          return Container(
            height: 0.0,
          );
        }
      case 'mentorizado':
        if(user['role'] == "mentorizado"){
          return _getAppCard(icon, publication, Colors.indigo);
        }else{
          return Container(
            height: 0.0,
          );
        }
      default:
        return _getAppCard(icon,publication, Colors.black);
    }
  }  

  Widget _getAppCard(Widget? icon, QueryDocumentSnapshot<Map<String, dynamic>> publication, Color colorDecoration){
    String username = publication['user'];
    Map<String, dynamic> likes = publication['likes'];
    Map<String, dynamic> comments = publication['comentarios'];
    bool liked = likes.containsValue(loggedInUser.email);
    Color background = Colors.white;
    Color decoration = colorDecoration;
    String title = publication['title'];
    Widget? trailing;
    Widget? photo = Container(height: 0.0);
    String description = publication['description'];
    if(publication["photo"] != ""){
      photo = _getHeroPhoto(publication["photo"], 200.0, publication);
    }
    if (username == loggedInUser.email){
      username = "Tú";
      background = const Color.fromARGB(255, 209, 73, 111);
      decoration = Colors.white;
      trailing = PopupMenuButton(
        tooltip: "Borrar la publicación",
        icon: const Icon(Icons.more_vert_rounded),
        itemBuilder: (context) => <PopupMenuEntry<Widget>>[
          PopupMenuItem(child: const Center(child:Text("Borrar publicación")), onTap: (){
            setState(() {
              _deletePublication(publication);
            });
          },) 
        ],
      );
    }
    else{
      if(widget.user!["role"] == "profesor"){
        trailing = PopupMenuButton(
          tooltip: "Borrar la publicación",
          icon: const Icon(Icons.more_vert_rounded),
          itemBuilder: (context) => <PopupMenuEntry<Widget>>[
            PopupMenuItem(
              child: const Center(
                child:Text("Borrar publicación")
              ), 
              onTap: (){
                setState(() {
                  _deletePublication(publication);
                });
              },
            ), 
            PopupMenuItem(
              child:  Center(
                child: liked ? const Text("Quitar like") : const Text("Dar like")
              ), 
              onTap: () {
                setState(() {
                  _changeLike(liked, publication, likes);
                });
              },    
            ), 
          ],
        );
      }else{
        trailing = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,    
          children:<Widget>[
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,    
                children:<Widget>[
                  IconButton(
                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                    tooltip: "Botón de me gusta la publicación",
                    icon: liked ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border_rounded),
                    color:  const Color.fromARGB(255, 180, 50, 87),
                    onPressed: () {
                      setState(() {
                        _changeLike(liked, publication, likes);
                      });
                    },
                  ),
                  Text(likes.length.toString()),
                ]
              ),
            ),
            Expanded(
              child:Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,  
                children:<Widget>[
                  IconButton(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    tooltip: "Botón para comentar la aplicación",
                    icon: const Icon(Icons.mode_comment_outlined),
                    color:  const Color.fromARGB(255, 180, 50, 87),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PublicationDetail(publication: publication, loggedInUser: loggedInUser,)));               
                    },
                  ),
                Text(comments.length.toString()),
                ],
              ),
            ),
          ]
        );
      }
    }
    return AppCard(
      active: false,
      trailing: trailing,
      color: background,
      radius: 3.0,
      borderColor: publication["challenge"] == null ? Colors.black : Colors.red,
      iconColor: decoration,
      textColor: decoration,
      leading: icon,
      photo: photo,
      title: Text.rich(
        TextSpan(
          text: '', 
          children: <TextSpan>[
            TextSpan(text: '$title\n', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
            TextSpan(text: username, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15.0)),
          ],
        ),
      ),
      subtitle: Text('\n$description'),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => PublicationDetail(publication: publication, loggedInUser: loggedInUser,)));
      }
    );
  }

  void _deletePublication( QueryDocumentSnapshot<Map<String, dynamic>> publication) async{
    if(publication["photo"] != ""){
      storage.deleteURL(publication["photo"]);
    }
    await FirestoreService().delete(document: publication.reference);
            
  }

  void _changeLike(bool liked, QueryDocumentSnapshot<Map<String, dynamic>> publication, Map<String, dynamic> likes) async{
    if(liked){
      // INFO: Quitar al usuario de la base de datos
      likes.remove(loggedInUser.email);
      await FirestoreService().update(document: publication.reference, collectionValues: {
        'likes': likes,
      });
    }else{
      // INFO: Añadir al usuario de la base de datos
      likes.addAll({
          loggedInUser.email! : loggedInUser.email
      });
      await FirestoreService().update(document: publication.reference, collectionValues: {
        'likes': likes,
      });
    }
  }

  Widget _getPhoto(String name, double height){
    try{
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
            child:Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox (
                height: height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    key: ValueKey<String>(snapshot.data!),
                    imageUrl: snapshot.data!,
                    placeholder: (context, url) => Platform.isAndroid ? 
                      const CircularProgressIndicator() 
                      : const CupertinoActivityIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              )
            ]
          ),
        )
        : Container(height: 0.0,);
      },
    );
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

  Widget _getHeroPhoto(String name, double height, QueryDocumentSnapshot<Map<String, dynamic>> publication){
    try{
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
            child:Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox (
                height: height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return DetailScreen(path: snapshot.data!, tag: publication.reference.toString(),);
                      }));
                    },
                    child: Hero(
                      tag: publication.reference.toString(),
                      child: CachedNetworkImage(
                        key: ValueKey<String>(snapshot.data!),
                        imageUrl: snapshot.data!,
                        placeholder: (context, url) => const Text ("Cargando..."),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
            ]
          ),
        )
        : Container(height: 0.0,);
      },
    );
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
}