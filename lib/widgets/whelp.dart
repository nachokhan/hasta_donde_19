import 'package:flutter/material.dart';

class WHelp extends StatelessWidget {
  final onPressCancel;
  final String helpText;

  WHelp(this.onPressCancel, this.helpText);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(20),
      borderOnForeground: true,
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Image(
                    image: AssetImage('assets/images/appicon.png'),
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Acerca de la App",
                      style: TextStyle(
                          fontSize: 20,
                          decorationStyle: TextDecorationStyle.double),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        //  side: BorderSide(color: Colors.white),
                      ),
                      child: Text("Volver"),
                      elevation: 6,
                      color: Color.fromARGB(240, 0, 126, 128),
                      textColor: Colors.white,
                      onPressed: onPressCancel,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5)),
                child: SingleChildScrollView(
                  child: Text(
                    helpText,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
