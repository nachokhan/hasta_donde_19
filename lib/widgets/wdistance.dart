import 'package:flutter/material.dart';

class WDistance extends StatelessWidget {
  final double _distance;
  final bool isTracking;
  final double maxAllowedMeters;
  final Function onOutOfRange;

  WDistance(this._distance, this.isTracking, this.maxAllowedMeters,
      this.onOutOfRange);

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

    if (_distance >= this.maxAllowedMeters) {
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
    if (!isTracking) {
      return "GPS is OFF";
    }

    var distancia = getDistanceWithUnitsAsString(_distance);

    String text = "Dist a casa: $distancia";

    if (_distance >= this.maxAllowedMeters) {
			onOutOfRange();
      var ex = getDistanceWithUnitsAsString(_distance - this.maxAllowedMeters);
      text += "\nExcedido en: $ex";
    }

    return text;
  }

  String getDistanceWithUnitsAsString(double dist) {
    var numero = dist.toStringAsFixed(1);
    var unidad = "m";

    if (dist >= 1000) {
      unidad = "Km";
      numero = (dist / 1000.0).toStringAsFixed(1);
    }

    return "$numero $unidad";
  }
}
