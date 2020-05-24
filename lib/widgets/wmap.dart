import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WMap extends StatelessWidget {
  final LatLng _homeLocation;
  final LatLng _recentlySearchedAdress;
  final Completer<GoogleMapController> _controller = Completer();
  final Function longPress;
  final Function returnController;
  final bool showLocation;

  WMap(this._homeLocation, this._recentlySearchedAdress, this.showLocation,
      this.returnController, this.longPress);

  @override
  Widget build(BuildContext context) {
    if (_homeLocation == null)
      return Center(child: Text("Esperando ubicación..."));
   
    return GoogleMap(
      onMapCreated: _onMapCreated,
      onLongPress: (pos) => longPress(pos),
      initialCameraPosition: CameraPosition(target: _homeLocation, zoom: 11.8),
      myLocationButtonEnabled: showLocation,
      myLocationEnabled: showLocation,
      markers: {
        Marker(
          markerId: MarkerId("home"),
          position: _homeLocation,
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
            center: _homeLocation),
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
		returnController(controller);
    _controller.complete(controller);
  }
}
