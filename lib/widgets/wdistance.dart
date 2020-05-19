import 'package:flutter/material.dart';

class WDistance extends StatelessWidget {
  final double _distance;
  final bool isTracking;

  WDistance(this._distance, this.isTracking);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        getStringDistance(),
        textAlign: TextAlign.center,
        style: getStringStyle(),
      ),
    );
  }

  TextStyle getStringStyle() {
    if (!isTracking) {
      return TextStyle(
        fontSize: 15,
        backgroundColor: Colors.black,
        color: Colors.white,
        fontStyle: FontStyle.italic,
      );
    }

    if (_distance >= 5000) {
      return TextStyle(
        fontSize: 20,
        backgroundColor: Colors.red,
        color: Colors.white,
      );
    }

    return TextStyle(
      fontSize: 18,
      backgroundColor: Colors.green,
      color: Colors.white,
    );
  }

  String getStringDistance() {
    String unidad = "m";
    String numero = _distance.toStringAsFixed(1);

    if (!isTracking) {
      return "GPS is OFF";
    }

    if (_distance >= 1000) {
      unidad = "Km";
      numero = (_distance / 1000.0).toStringAsFixed(1);
    }

    return "Dist a casa: $numero $unidad";
  }
}
