import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/screens/detail/team_detail.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:esi_tfg_app/src/services/storage_service.dart';

class UserDetail extends StatelessWidget {
  final Storage storage = Storage();
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  UserDetail({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> splitName = user!['email'].toString().split('@');
    String email = splitName.first;
    List<String> splitDate = user!['sign_up_date'].toDate().toString().split(' ');
    String date = splitDate.first;
    String status = user!['status'].toString();
    return Scaffold(
        appBar: AppBar(
          title: const Text("User"),
        ),
      body: SingleChildScrollView(
        child:Container(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center, 
                children:<Widget>[
                  user!["image"] != "" ? _getPhoto(user!["image"], 100.0): const Icon(Icons.person, size: 100.0,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0) ,
                    child: Center(
                      child: Text(email, style: const TextStyle(color: Color.fromARGB(255, 180, 50, 87),fontSize: 25.0, fontWeight: FontWeight.w700)),
                    ),
                  )
                ]
              ),
              const SizedBox(height: 10.0,),
              const Divider(thickness: 1.0, color: Colors.black,),
              const SizedBox(height: 10.0,), 
              const Text("Miembro desde:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
              Text(date, style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),),
              const SizedBox(height: 10.0,), 
              const Divider(thickness: 1.0, color: Colors.black,),            
              const SizedBox(height: 10.0,), 
              const Text("Rol:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
              Text(user!['role'].toString().toUpperCase(), style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),),
              const SizedBox(height: 10.0,),
              const Divider(thickness: 1.0, color: Colors.black,),            
              const SizedBox(height: 10.0,),
              const Text("Nivel de experiencia:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,    
                children:<Widget>[
                    _getStatus(user!['status']),
                    Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0) ,
                    child: Center(
                      child: Text(" ($status px)", style: const TextStyle(color: Color.fromARGB(255, 180, 50, 87),fontSize: 25.0, fontWeight: FontWeight.w700)),
                    ),
                  )
                ]
              ),
              const SizedBox(height: 10.0,),
              const Divider(thickness: 1.0, color: Colors.black,),            
              const SizedBox(height: 10.0,),
              const Text("Retos completados:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
              _getList(context, "challenges", false),
              const SizedBox(height: 10.0,),
              const Divider(thickness: 1.0, color: Colors.black,),            
              const SizedBox(height: 10.0,),
              const Text("Equipo/s:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700),),
              _getList(context,"teams", true),
              
            ]
          )
        ),
      ),
    );
  }

  Widget _getStatus(int status){
    if(status > 10000){
      return const Text("Leyenda", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
    }if(status > 5000){
      return const Text("Experto 4", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
    }if(status > 3000){
      return const Text("Experto 3", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
    }if(status > 2000){
      return const Text("Experto 2", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
    }if(status > 1200){
      return const Text("Experto 1", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
    }if(status > 800){
      return const Text("Intermedio 3", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
    }if(status > 500){
      return const Text("Intermedio 2", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
    }if(status > 200){
      return const Text("Intermedio 1", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
    }if(status > 100){
      return const Text("Principiante 3", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
    }if(status > 40){
      return const Text("Principiante 2", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
    }else{
      return const Text("Principiante 1", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),);
    }
  }

  Widget _getPhoto(String name, double height){
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
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover
                    )
                ),
              )
            ]
          )
        )
        : Container(height: 0.0,);
      },
    );
  }

  Widget _getList(BuildContext context, String collectionName, bool decider){
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirestoreService().getMessage(collectionName: collectionName),
      builder: (context, snapshot){
        if(snapshot.hasData){
          var messages = snapshot.data!.docs;
          return Flexible(
            fit: FlexFit.loose,
            child: SizedBox(
              height: decider ? 200.0: 60.0,
              child:ListView(
                children: decider ? _getTeacherItems(context, messages) : _getChallengeItems(context, messages),
              )
            )
          );
        }else{
          return Container(
            height: 0.0,
          );
        }
      },
    );
  }

  List<Widget> _getTeacherItems(BuildContext context, dynamic messages){
    List<Widget> messageItems = [];
    Map<String, dynamic> teamsMap = user!['team'];
    Iterable<dynamic> teams = teamsMap.values;
    for(var team in teams){
      var selectedTeam = messages.firstWhere((element) => element.reference == team);
      var name = selectedTeam['name'].toString();
      messageItems.add(
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 209, 73, 111),
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TeamDetail(team: selectedTeam)));
          },
          child: Text("Equipo $name"),
        ),
      );
    }
    return messageItems;
  }

  List<Widget> _getChallengeItems(BuildContext context, dynamic messages){
    List<Widget> messageItems = [], bronzeItems = [], silverItems = [], goldItems = [];
    int goldCount = 0, silverCount = 0, bronzeCount = 0;
    Map<String, dynamic> challengesMap = user!['challenges_completed'];
    Iterable<dynamic> challenges = challengesMap.values;
    for(var challenge in challenges){
      var selectedChallenge = messages.firstWhere((element) => element.reference == challenge);
      String name = selectedChallenge["name"];
      switch(selectedChallenge["level"]){
        case 1:
          bronzeCount +=1;
          bronzeItems.add(
            Padding(
              padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
              child:Text("Reto: $name", style: const TextStyle(fontSize: 20.0),)
            )
          );
          break;
        case 5:
          silverCount +=1;
          silverItems.add(
            Padding(
              padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
              child:Text("Reto: $name", style: const TextStyle(fontSize: 20.0),)
            )
          );
          break;
        case 20:
          goldCount +=1;
          goldItems.add(
            Padding(
              padding: const EdgeInsets.only(left: 15.0, bottom: 15.0),
              child:Text("Reto: $name", style: const TextStyle(fontSize: 20.0),)
            )
          );
          break;
      }
    }
    messageItems.add(
      Center(
        child: Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center, 
          children: <Widget>[
            Image.asset('images/gold.png',height: 40.0),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 209, 73, 111),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _getModalSheet(context, goldItems);
              },
              child:Text(goldCount.toString()),
            ),
            Image.asset('images/silver.png',height: 40.0),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 209, 73, 111),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                 _getModalSheet(context, silverItems);
              },
              child:Text(silverCount.toString()),
            ),
            Image.asset('images/bronze.png',height: 40.0),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 209, 73, 111),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _getModalSheet(context, bronzeItems);
              },
              child:Text(bronzeCount.toString()),        
            )
          ]
        )
      )
    );
    return messageItems;
  }

  Future<dynamic> _getModalSheet(BuildContext context, List <Widget> challenges){
    return showModalBottomSheet(
      context: context, 
      builder: (BuildContext context){
        return SizedBox(
          height: 400.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[ 
              const SizedBox(height: 20.0,),
              const Center(child:Text("Retos conseguidos", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w700),),),
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
                      itemCount: challenges.length,
                      itemBuilder: (context, index) =>
                        challenges[index]
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
}