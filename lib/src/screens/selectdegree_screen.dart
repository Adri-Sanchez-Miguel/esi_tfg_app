import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esi_tfg_app/src/services/firestore_service.dart';
import 'package:esi_tfg_app/src/widgets/app_button.dart';
import 'package:esi_tfg_app/src/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class SelectDegree extends StatefulWidget {
  static const String routeName = '/selectdegree';
  final QueryDocumentSnapshot<Map<String, dynamic>>? user;
  const SelectDegree({Key? key, this.user}) : super(key: key);

  @override
  State<SelectDegree> createState() => _SelectDegreeState();
}

class _SelectDegreeState extends State<SelectDegree> {
  bool _showSpinner = false;
  bool _completed = false; 
  QueryDocumentSnapshot? _degree;

  void setSpinnersStatus(bool status){
    setState(() {
      _showSpinner = status;
    });
  }

  @override
  Widget build(BuildContext context){
    setSpinnersStatus(false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Grado"),
        backgroundColor: const Color.fromARGB(255, 180, 50, 87),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showSpinner,
        child:Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,    
            children:  <Widget>[
              const Text("Elige tu titulación:", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w700, color: Color.fromARGB(255, 180, 50, 87)),),
              const SizedBox(height: 10.0,), 
              _getNameDegree(),
              const SizedBox(height: 15.0,), 
              _selectDegree(),
              const SizedBox(height: 20.0,),
              _getBack()
            ]
          ),
        ),
      ),
    );
  }

  Widget _selectDegree() {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirestoreService().getMessage(collectionName: "degrees"),
      builder: (context, snapshot){
        try{
          if(snapshot.hasData){
            return Flexible(
              child: ListView.builder(
                addRepaintBoundaries: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) =>
                  _getDegree(context, snapshot.data!.docs[index]),
              ),
            );
          }else{
            return Container(
              height: 0.0,
            );
          }
        }catch(e){
          Fluttertoast.showToast(
            msg: e.toString(),
            fontSize: 20,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red[400]
          );
          return Container (height: 0.0,);
        }
      }
    );
  }
  
  Widget _getDegree(BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    Color? color = Color.fromARGB(doc['color'][0], doc['color'][1], doc['color'][2], doc['color'][3]);
    String title = doc['titulo'].toString();
    String subtitle = doc['facultad'].toString();
    return AppCard(
      radius: 2.0,
      borderColor: Colors.black12,
      iconColor: Colors.white,
      textColor: Colors.white,
      color: color,
      leading: const Icon(Icons.auto_stories),
      title: Text(title,
        style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
      ),
      subtitle: Text(subtitle),
      onTap: (){
        setState(() {
          _completed = true;
          _degree = doc;
        });
      }
    );
  }

  void _changeUserDegree() async{
    if(widget.user!=null){
      await FirestoreService().update(document: widget.user!.reference, collectionValues: {
        'degree': _degree!['titulo'] 
      }); 
    }
  }

  Widget _getNameDegree(){
    if(_completed){
      String carrera = _degree!['titulo'];
      return Center(
        child: Text(
          "Carrera elegida:\n $carrera", style: const TextStyle(fontSize: 25.0,  fontWeight: FontWeight.bold),)
      );
    }else{
      return Container(height:0.0);
    }
  }

  Widget _getBack(){
    if(_completed){
      return AppButton(
        color: const Color.fromARGB(255, 180, 50, 87),
        colorText: Colors.white,
        name: "Confirmar",
        onPressed:()async{
          _changeUserDegree();
          Navigator.pop(context);
          Navigator.pushNamed(context, "/home");
        }
      );
    }else{
      return AppButton(
        color:Colors.black54,
        colorText: Colors.white54,
        name: "Elija un grado",
        onPressed:()async{}
      );
    }
  }
}