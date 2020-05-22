import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import './models/states.dart';
import './controllers/assetsController.dart';
import './controllers/locationController.dart';

import './widgets/whelp.dart';
import './widgets/wselecthome.dart';
import './widgets/wOptionsMenu.dart';
import './widgets/wdistance.dart';
import './widgets/wmap.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '¿Por dónde andar?',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //home: MyHomePage(title: '¿Por dónde 🚴🏾‍♂️🏃🏾?'),
      home: MyHomePage(title: '¿Por dónde andar?'),
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
  LatLng _myHome;
  LatLng _myPosition;
  double _distance = 0.0;
  final double _maxAllowedMeters = 5000;
  LatLng recentlySearchedAddress;
  LatLng newHome;

  var appState = eAppStates.MapScreen;
  var trackLocation = false;
  var showAddressSearch = false;
  var showAddAsHome = false;
  var locationPermission = false;

  String helpText;

  @override
  void initState() {
    super.initState();

    Permission.location.request().then((value) {
      if (value == PermissionStatus.granted)
        setState(() {
          locationPermission = true;
          changeGetLocation();
        });
      else
        SystemNavigator.pop();
    });

    loadTextAsse2t("assets/text/help.txt").then((value) {
      setState(() {
        helpText = value;
      });
    });

    loadHomeLocationFromDisk().then((val) {
      setState(() {
        _myHome = val;
      });
    });

    if (locationPermission)
      GeoLocationController().getUserLocation().then(
          (value) => _myPosition = LatLng(value.latitude, value.longitude));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Color.fromARGB(255, 0, 128, 126),
        leading: Image.asset('assets/images/appicon.png'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => onPressSelectHome(),
          ),
          if (locationPermission)
            IconButton(
              icon: Icon(Icons.router),
              color: trackLocation ? Colors.white : Colors.grey,
              onPressed: changeGetLocation,
            ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              setState(() {
                appState = eAppStates.HelpScreen;
              });
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          if (appState == eAppStates.MapScreen) ...getMapScreenWidgets(),
          if (appState == eAppStates.HelpScreen)
            WHelp(() => setAppState(eAppStates.MapScreen), helpText),
          if (showAddressSearch)
            WSelectHome((newHome) => onAddressSelected(newHome)),
          if (showAddAsHome)
            WOptionsMenu(changeHomeAddress, cancelHomeSelection),
        ],
      ),
    );
  }

  List<Widget> getMapScreenWidgets() {
    return [
      WMap(
        _myHome,
        recentlySearchedAddress,
        trackLocation,
        (pos) => onAddressSelected(pos),
      ),
      WDistance(_distance, trackLocation, _maxAllowedMeters),
    ];
  }

  changeGetLocation() {
    if (!locationPermission) return;

    if (trackLocation) {
      setState(() {
        trackLocation = false;
      });
      GeoLocationController().stopListening();
    } else {
      setState(() {
        trackLocation = true;
      });
      GeoLocationController().startListening((pos) => onPositionChanged(pos));
    }
  }

  onPositionChanged(Position pos) {
    setState(() {
      _myPosition = LatLng(pos.latitude, pos.longitude);
      GeoLocationController()
          .calculateDistanceToHome(_myPosition, _myHome)
          .then((value) => _distance = value);
    });
  }

  void cancelHomeSelection() {
    setState(() {
      recentlySearchedAddress = null;
      showAddAsHome = false;
    });
  }

  void onAddressSelected(LatLng newAddress) {
    setState(() {
      recentlySearchedAddress = newAddress;
      showAddAsHome = true;
    });
  }

  changeHomeAddress() {
    setState(() {
      if (recentlySearchedAddress != null) {
        _myHome = recentlySearchedAddress;
        saveHomeLocationInDisk();
        showAddressSearch = false;
        showAddAsHome = false;
      }
    });
    recentlySearchedAddress = null;
  }

  onPressSelectHome() {
    setState(() {
      showAddressSearch = !showAddressSearch;
      showAddAsHome = false;
      recentlySearchedAddress = null;
    });
  }

  void saveHomeLocationInDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("homeLatitude", _myHome.latitude);
    await prefs.setDouble("homeLongitude", _myHome.longitude);
  }

  Future<LatLng> loadHomeLocationFromDisk() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double lat = prefs.getDouble("homeLatitude");
    double lon = prefs.getDouble("homeLongitude");

    LatLng pos;

    if (lat != null && lon != null) {
      pos = LatLng(lat, lon);
    } else {
      if (locationPermission) {
        await GeoLocationController().getUserLocation().then((value) {
          setState(() {
            pos = LatLng(value.latitude, value.longitude);
          });
        });
      } else {
        setState(() {
          trackLocation = false;
          locationPermission = false;
          pos = LatLng(-32.8908400, -68.8271700);
        });
      }
    }

    return pos;
  }

  setAppState(eAppStates state) {
    setState(() {
      appState = state;
    });
  }
}
