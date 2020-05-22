import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WMap extends StatelessWidget {
  final LatLng _initialPos;
  final LatLng _recentlySearchedAdress;
  final Completer<GoogleMapController> _controller = Completer();
  final Function longPress;
  final bool showLocation;

  WMap(this._initialPos, this._recentlySearchedAdress, this.showLocation,
      this.longPress);

  @override
  Widget build(BuildContext context) {
    if (_initialPos == null)
      return Center(child: Text("Esperando ubicación..."));

    return GoogleMap(
      onMapCreated: _onMapCreated,
      onLongPress: (pos) => longPress(pos),
      initialCameraPosition: CameraPosition(target: _initialPos, zoom: 11.8),
      myLocationButtonEnabled: showLocation,
      myLocationEnabled: showLocation,
      markers: {
        //if (_recentlySearchedAdress == null)
        Marker(
          markerId: MarkerId("home"),
          position: _initialPos,
          infoWindow: InfoWindow(title: "Casa"),
        ),
        if (_recentlySearchedAdress != null)
          Marker(
              markerId: MarkerId("recentlySearched"),
              position: _recentlySearchedAdress,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen)),
      },
      circles: {
        Circle(
            circleId: CircleId("home"),
            radius: 5000,
            strokeWidth: 1,
            fillColor: Color.fromRGBO(20, 255, 0, 220),
            center: _initialPos),
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
}
