import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

//import './widgets/wselecthome.dart';
import './controllers/locationController.dart';
import './widgets/wOptionsMenu.dart';
import './widgets/wdistance.dart';
import './widgets/wmap.dart';
import './models/states.dart';

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
        setState(() {
          locationPermission = false;
          trackLocation = false;
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
          /*IconButton(
            icon: Icon(Icons.search),
            onPressed: () => onPressSelectHome(context),
          ),*/
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
          if (appState == eAppStates.HelpScreen) ...getHelpScreenWidgets(),
          /*showAddressSearch
                        ? WSelectHome((newHome) => onNewAddressSearched(newHome))
                        : Container(),*/
          WOptionsMenu(showAddAsHome, changeHomeAddress, cancelHomeSelection),
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
        (pos) => onNewAddressSearched(pos),
      ),
      WDistance(_distance, trackLocation, _maxAllowedMeters),
    ];
  }

  getHelpScreenWidgets() {
    return [
      Card(
        elevation: 5,
        margin: EdgeInsets.all(20),
        borderOnForeground: true,
        child: Container(
          child: Column(
            children: <Widget>[
              Text(
                "Acerca de la App",
                style: TextStyle(
                    fontSize: 30, decorationStyle: TextDecorationStyle.double),
              ),
              Text(
                """¿Por Dónde Andar? es una app para en todo momento sepas si estás o no dentro de los 5km permitidos.\n\nLa primera vez que usas la App tenés que indicar dónde está tu casa. Actualmente, la forma de hacer esto ir en el mapa a donde vivis y mantener presionando con el dedo. Seguido de esto te va a aparecer un cosito verde y un botón que dice \"Es mi casa\". Si lo parsionás, guardás ese lugar como tu casa.\n\nSi querés cambiar el lugar donde tu vivís, repetís ese procedimiento. ¡Es muy fácil!. \n\nNacho L.""",
                style: TextStyle(fontSize: 18),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                    child: Text("Volver"),
                    color: Color.fromARGB(240, 0, 126, 128),
                    textColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        appState = eAppStates.MapScreen;
                      });
                    }),
              ),
            ],
          ),
        ),
      )
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

  void onNewAddressSearched(LatLng newAddress) {
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

  onPressSelectHome(BuildContext context) {
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
}
