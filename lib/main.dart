import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:por_donde/controllers/locationController.dart';
import 'package:por_donde/widgets/wOptionsMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

//import './widgets/wselecthome.dart';
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
  //static LatLng _initialCameraPos = LatLng(-32.9556782, -68.8547009);
  LatLng _myHome;// = _initialCameraPos;
  LatLng _myPosition;
  double _distance = 0.0;
  final double _maxAllowedMeters = 5000;

  LatLng recentlySearchedAddress;

  var trackLocation = false;
  var showAddressSearch = false;
  var showAddAsHome = false;
  var locationPermission = false;

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

  LatLng newHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Color.fromARGB(255, 0, 128, 126),
        leading: Image.asset('assets/images/appicon.png'),
        actions: <Widget>[
          /*  IconButton(
            icon: Icon(Icons.search),
            onPressed: () => onPressSelectHome(context),
          ),*/
          locationPermission
              ? IconButton(
                  icon: Icon(Icons.track_changes),
                  onPressed: changeGetLocation,
                )
              : Container(),
          //IconButton(icon: null, onPressed: null)
        ],
      ),
      body: Stack(
        children: <Widget>[
          WMap(
            _myHome,
            recentlySearchedAddress,
            trackLocation,
            (pos) => onNewAddressSearched(pos),
          ),
          WDistance(_distance, trackLocation, _maxAllowedMeters),
          /*showAddressSearch
              ? WSelectHome((newHome) => onNewAddressSearched(newHome))
              : Container(),*/
          WOptionsMenu(showAddAsHome, changeHomeAddress, cancelHomeSelection),
        ],
      ),
    );
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
