import 'dart:async';

import 'package:geolocator/geolocator.dart';

class GeoLocationController {
  /////////////////////////////////////////////////////
  /// Singleton Pattern
  ///
  static final GeoLocationController _instance =
      GeoLocationController._internal();

  factory GeoLocationController() {
    return _instance;
  }
  GeoLocationController._internal();
  /////////////////////////////////////////////////////

  StreamSubscription<Position> _strSubscription;
  Stream<Position> _posStream;

  /// Starts listeing to the GPS and whenever the location changes
  /// it calls the onPositionChanged funcion with the new position.
  void startListening(Function onPositionChanged) {
    if (_strSubscription == null) {
      const LocationOptions locOptions =
          LocationOptions(accuracy: LocationAccuracy.best);

      _posStream = Geolocator().getPositionStream(locOptions);

      _strSubscription = _posStream.listen((pos) {
        onPositionChanged(pos);
      });
    }
  }

  /// Stop Listening or receiving location changes
  void stopListening() {
    if (_strSubscription != null) {
      _strSubscription.cancel();
      _strSubscription = null;
      _posStream = null;
    }
  }

  Future<double> calculateDistanceToHome(var myPos, var myHome) async {
    var distance = await Geolocator().distanceBetween(
        myHome.latitude, myHome.longitude, myPos.latitude, myPos.longitude);

    return distance;
  }

  Future<Position> getUserLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return currentLocation;
  }
}
