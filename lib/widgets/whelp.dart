import 'package:flutter/material.dart';

class WHelp extends StatelessWidget {
  final onPressCancel;

  WHelp(this.onPressCancel);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(20),
      borderOnForeground: true,
      child: Container(
        child: Column(
          children: <Widget>[
            Text(
              "Acerca de la App",
              style: TextStyle(
                  fontSize: 30, decorationStyle: TextDecorationStyle.double),
            ),
            Text(
              """¿Por Dónde Andar? es una app para en todo momento sepas si estás o no dentro de los 5km permitidos.\n\nLa primera vez que usas la App tenés que indicar dónde está tu casa. Actualmente, la forma de hacer esto ir en el mapa a donde vivis y mantener presionando con el dedo. Seguido de esto te va a aparecer un cosito verde y un botón que dice \"Es mi casa\". Si lo parsionás, guardás ese lugar como tu casa.\n\nSi querés cambiar el lugar donde tu vivís, repetís ese procedimiento. ¡Es muy fácil!. \n\nNacho L.""",
              style: TextStyle(fontSize: 18),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                child: Text("Volver"),
                color: Color.fromARGB(240, 0, 126, 128),
                textColor: Colors.white,
                onPressed: onPressCancel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
