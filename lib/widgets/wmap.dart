import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WMap extends StatelessWidget {
  final CameraPosition _initialPosition;
  final LatLng _myHome;
  Completer<GoogleMapController> _controller = Completer();

  WMap(this._initialPosition, this._myHome);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: _initialPosition,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      markers: {
        Marker(markerId: MarkerId("home"), position: _myHome),
      },
      circles: {
        Circle(
            circleId: CircleId("home"),
            radius: 5000,
            strokeWidth: 1,
            fillColor: Color.fromRGBO(20, 255, 0, 220),
            center: _myHome),
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
}
