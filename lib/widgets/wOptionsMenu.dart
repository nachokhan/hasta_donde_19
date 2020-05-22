import 'package:flutter/material.dart';

class WOptionsMenu extends StatelessWidget {
  final Function changeHomeAddress;
  final Function cancelHomeSelection;

  WOptionsMenu(this.changeHomeAddress, this.cancelHomeSelection);

  @override
  Widget build(BuildContext context) {
    Widget wid;

    wid = Stack(
      children: <Widget>[
        Positioned(
          top: 60,
          height: 40,
          right: 15,
          child: RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textColor: Colors.white,
            color: Color.fromARGB(255, 0, 128, 120),
            elevation: 5,
            child: Text("Es mi Casa!"),
            onPressed: changeHomeAddress,
          ),
        ),
        Positioned(
          top: 105,
          height: 40,
          right: 15,
          child: RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textColor: Colors.white,
            color: Color.fromARGB(255, 0, 128, 120),
            elevation: 5,
            child: Text("Cancelar"),
            onPressed: cancelHomeSelection,
          ),
        ),
      ],
    );

    return wid;
  }
}
