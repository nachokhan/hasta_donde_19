import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import './widgets/wselecthome.dart';
import './widgets/wdistance.dart';
import './widgets/wmap.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MendoBike',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: '¿Por dónde 🚴🏾‍♂️🏃🏾?'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static LatLng _initialCameraPosition = LatLng(-32.9556782, -68.8547009);
  var _myHome = _initialCameraPosition;
  LatLng _myPosition;
  double _distance = 0.0;
  CameraPosition _initialPosition =
      CameraPosition(target: _initialCameraPosition, zoom: 12);
  final double _maxAllowedMeters = 5000;

  var trackLocation = false;
  var showHomeSelector = false;

  StreamSubscription<Position> strSubscription;

  getLocation() {
    if (trackLocation) {
      setState(() {
        trackLocation = false;
      });
      strSubscription.cancel();
      strSubscription = null;
    } else {
      setState(() {
        trackLocation = true;
      });
      if (strSubscription == null) {
        const LocationOptions locOptions =
            LocationOptions(accuracy: LocationAccuracy.best);
        final Stream<Position> posStream =
            Geolocator().getPositionStream(locOptions);

        strSubscription = posStream.listen((Position pos) {
          setState(() {
            _myPosition = LatLng(pos.latitude, pos.longitude);
            calculateDistanceToHome();
          });
        });

        strSubscription.onDone(() {
          setState(() {
            trackLocation = false;
          });
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  LatLng newHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () => onPressSelectHome(context)),
          IconButton(icon: Icon(Icons.track_changes), onPressed: getLocation),
          //IconButton(icon: null, onPressed: null)
        ],
      ),
      body: Stack(
        children: <Widget>[
          WMap(this._initialPosition, _myHome),
          WDistance(_distance, trackLocation, _maxAllowedMeters),
          showHomeSelector ? WSelectHome((newHome) => onChangeHomeAddress(newHome)): Container(),
        ],
      ),
    );
  }

  onChangeHomeAddress(LatLng newHome) {
    setState(() {
      _myHome = newHome;
      showHomeSelector = false;
    });
  }

  onPressSelectHome(BuildContext context) {
    setState(() {
      showHomeSelector = !showHomeSelector;
    });
  }

  getSelectHomeWidget(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => print("soltame jiji"),
      onTap: () => {},
      child: WSelectHome((newHome) => onChangeHomeAddress(newHome)),
    );
  }

  /// GET USER LOCATION
  getUserLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _myPosition = LatLng(currentLocation.latitude, currentLocation.longitude);
    });

    await calculateDistanceToHome();
  }

  /// GET DISTANCE FROM myPos to myHome
  Future calculateDistanceToHome() async {
    _distance = await Geolocator().distanceBetween(_myHome.latitude,
        _myHome.longitude, _myPosition.latitude, _myPosition.longitude);
  }
}
