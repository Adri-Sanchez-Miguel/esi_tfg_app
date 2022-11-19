import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroductionPages extends StatelessWidget {
  static const String routeName = "/introduccion"; 
  const IntroductionPages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:IntroductionScreen(
        pages: listPagesViewModel(),
        done: const Text("Hecho", style: TextStyle(fontWeight: FontWeight.w600)),
        next: const Text('Siguiente') ,
        showBackButton: true,
        showSkipButton: false,
        back: const Icon(Icons.arrow_back),
        onDone: () {
          Navigator.pop(context);
        },
      )
    ); 
  }

  List<PageViewModel>? listPagesViewModel(){
    List<PageViewModel>? listPagesView = [
      PageViewModel(
        title: "¡Hola!",
        body: "Te damos la bienvenida al Programa Menthor, una aplicación diseñada para mejorar el ambiente en tu facultad, que conozcas a alumnos como tú y sobre todo ¡que lo pases bien!",
        image: Center(
          child: Image.asset('images/menthor_logo.png', height: 125.0),
        ),
      ),
      PageViewModel(
        title: "¡A por los retos!",
        body: "Haz click en + para crear un nuevo reto o reclamar otros de la ventana 'Mis retos' que puedes conseguir a través de un código QR. Estos códigos podrán ser escaneados en lugares específicos o pidiéndolos a otros usuarios que los podrán encontrar en su ventana de 'Otros retos'. Para algunos retos, solo tendrás que subir una foto que asegure haber completado el reto ¡sin necesidad de escanear un QR!",
        image: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('images/gold.png',height: 100.0),
              Image.asset('images/silver.png',height: 100.0),
              Image.asset('images/bronze.png',height: 100.0),
            ]
          )
        ),
        decoration: PageDecoration(
          titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30.0),
          bodyTextStyle: const TextStyle(color: Colors.white, fontSize: 20.0),
          pageColor: Colors.red[600],
        ),
      ),
      PageViewModel(
        title: "Compite y comparte",
        body: "Junto a tu equipo, trata de conseguir el mayor número de logros posibles, y compártelos con todo el mundo en el muro, junto a otros mensajes que todo el que tú quieras puede ver. También puedes ver cúantos logros tienen otros equipos o usuarios.",
        image: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child:Image.asset('images/menthor_icon.png', height: 175.0),
          ),
        ),
      ),
      PageViewModel(
        title: "Últimos detalles",
        body: "Si tienes cualquier problema, no dudes en contactar con tu profesor, mentor o con el correo menthor.uclm@gmail.com. ¡A disfrutar!",
        image: Center(
          child: Image.asset('images/UCLM.png', height: 150.0),
        ),
      ),
    ];
    return listPagesView;
  }
}