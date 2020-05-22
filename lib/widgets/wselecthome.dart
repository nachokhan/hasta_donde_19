import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WSelectHome extends StatefulWidget {
  final Function onAddressSelected;

  WSelectHome(this.onAddressSelected);

  @override
  _WSelectHomeState createState() => _WSelectHomeState();
}

class _WSelectHomeState extends State<WSelectHome> {
  String address;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 5,
          left: 15,
          right: 15,
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black),
              color: Colors.white,
            ),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Address",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchAndNavigate,
                  iconSize: 30.0,
                ),
              ),
              onSubmitted: (value) => searchAndNavigate(),
              onChanged: (value) {
                setState(() {
                  address = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  searchAndNavigate() {
    Geolocator().placemarkFromAddress(address).then((value) {
      if (value != null) {
        double lat = value[0].position.latitude;
        double lon = value[0].position.longitude;
        widget.onAddressSelected(LatLng(lat, lon));
      }
    });
  }
}
