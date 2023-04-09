import 'dart:async';
import 'dart:convert';

import 'package:avandra/resources/authentication.dart';
import 'package:avandra/widgets/maps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:avandra/resources/secrets.dart'; // Stores the Google Maps API Key
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart' as mapLauch;

import 'dart:math' show asin, cos, qrt, sqrt;

import '../model/markers.dart';
import '../resources/validator.dart';
import '../utils/fonts.dart';
import '../widgets/input_box.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({Key? key}) : super(key: key);

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  late GoogleMapController mapController;

  late Position _currentPosition;
  late double _destinationLatitude;
  late double _destinationLongitude;

  String _currentAddress = '';

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;
  String? _selectedMarkerName = null;

  Set<Marker> markers = {};

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? suffixIcon,
    required Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextFormField(
        style: GoogleFonts.montserrat(
          fontSize: regularTextSize,
          color: regularTextSizeColor,
        ),
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
          hintStyle: GoogleFonts.montserrat(
            fontSize: smallerTextSize,
            color: smallerTextColor,
          ),
        ),
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      // _getCurrentLocation();
      List<Location> startPlacemark = await locationFromAddress(_startAddress);

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      double startLatitude = _startAddress == _currentAddress
          ? _currentPosition.latitude
          : startPlacemark[0].latitude;

      double startLongitude = _startAddress == _currentAddress
          ? _currentPosition.longitude
          : startPlacemark[0].longitude;
      /*double startLatitude = _currentPosition.latitude;

      double startLongitude = _currentPosition.longitude;
      */

      double destinationLatitude = _destinationLatitude;
      double destinationLongitude = _destinationLongitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      // Start Location Marker
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
          snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Adding the markers to the list
      markers.add(startMarker);
      markers.add(destinationMarker);

      print(
        'START COORDINATES: ($startLatitude, $startLongitude)',
      );
      print(
        'DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)',
      );

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

      // Accommodate the two locations within the
      // camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      double totalDistance = 0.0;

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        print('DISTANCE: $_placeDistance km');
      });

      final availableMaps = await mapLauch.MapLauncher.installedMaps;
      print(availableMaps);

      await availableMaps.first.showDirections(
          destination:
              mapLauch.Coords(_destinationLatitude, _destinationLongitude),
          originTitle: "My Location",
          origin: /* mapLauch.Coords(
              _currentPosition.latitude, _currentPosition.longitude)*/
              mapLauch.Coords(startLatitude, startLongitude), 
          directionsMode: mapLauch.DirectionsMode.walking);
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  @override
  void initState() {
    access();
    super.initState();
    _getCurrentLocation();
    _getAddress();
  }

  late String CBURole = "Test";
  void access() async {
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid);
    await documentReference.get().then((snapshot) {
      CBURole = snapshot.get("CBUAccess").toString();
    });
  }

  Future<void> addUserPin(MarkerData marker) {
    access();
    CollectionReference pinsCollection;
    if (CBURole == "Admin") {
      pinsCollection = FirebaseFirestore.instance.collection("CBUClassRooms");
    } else {
      pinsCollection = FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('pins');
    }
    print(CBURole);
    return pinsCollection.add({
      'latitude': marker.latitude,
      'longitude': marker.longitude,
      'title': marker.title,
      'address': marker.address,
    });
  }

  void _onMapTapped(LatLng position) async {
    String title = await _getPinAddress(position);
    String address = await _getPinAddress(position);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Name Your Pin'),
          content: Column(
            children: [
              Text("Current pin name: $title"),
              TextField(
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
                decoration: InputDecoration(hintText: 'Text'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                MarkerData markerData = MarkerData(
                    position.latitude, position.longitude, title, address);
                await addUserPin(markerData);
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Pin Created!'),
                      content: Text('You have successfully created a pin'),
                      actions: [
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void _addPinAtLocation(double latitude, double longitude) async {
    LatLng position = LatLng(latitude, longitude);
    String title = await _getPinAddress(position);
    String address = await _getPinAddress(position);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Name Your Pin'),
          content: Column(
            children: [
              Text("Current pin name: $title"),
              TextField(
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
                decoration: InputDecoration(hintText: 'Text'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                MarkerData markerData =
                    MarkerData(latitude, longitude, title, address);
                await addUserPin(markerData);
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Pin Created!'),
                      content: Text('You have successfully created a pin'),
                      actions: [
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> _getPinAddress(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks.first;
    return '${placemark.name}, ${placemark.locality}';
  }

  final TextEditingController searchController = TextEditingController();
  final StreamController<List<MarkerData>> mapMarkersStreamController =
      StreamController<List<MarkerData>>.broadcast();

  void searchMapMarkers(String searchQuery) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('CBUClassRooms')
        .where('title', isGreaterThanOrEqualTo: searchQuery)
        .where('title', isLessThanOrEqualTo: searchQuery + '\uf8ff')
        .get();

    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    final QuerySnapshot snapshot = await userDoc.reference
        .collection('pins')
        .where('title', isGreaterThanOrEqualTo: searchQuery)
        .where('title', isLessThanOrEqualTo: searchQuery + '\uf8ff')
        .get();

    final List<QueryDocumentSnapshot> documentSnapshots =
        querySnapshot.docs + snapshot.docs;
    final List<MarkerData> mapMarkers = documentSnapshots
        .map((docSnapshot) => MarkerData(
              docSnapshot.get('latitude'),
              docSnapshot.get('longitude'),
              docSnapshot.get('title'),
              docSnapshot.get('address'),
            ))
        .toList();
    mapMarkersStreamController.add(mapMarkers);
    _selectedMarkerName = null;
  }

  Future<List<Marker>> getUserMarkers() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    QuerySnapshot snapshot = await userDoc.reference.collection('pins').get();
    List<MarkerData> markerDataList = snapshot.docs
        .map((doc) => MarkerData(
              doc['latitude'],
              doc['longitude'],
              doc['title'],
              doc['address'],
            ))
        .toList();
    return markerDataList
        .map((markerData) => Marker(
              markerId: MarkerId(markerData.title),
              position: LatLng(markerData.latitude, markerData.longitude),
              infoWindow: InfoWindow(title: markerData.title),
            ))
        .toList();
  }

  @override
  void dispose() {
    destinationAddressController.dispose();
    startAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            // Map View
            GoogleMap(
              onTap: (latLng) {
                _onMapTapped(latLng);
              },
              markers: Set<Marker>.from(markers),
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            //Menu Button
            SafeArea(
                child: Align(
              alignment: Alignment.centerRight,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange.shade100, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.menu),
                        ),
                        onTap: () => Navigator.of(context)
                            .pushNamedAndRemoveUntil('/Menu', (route) => false),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange.shade100, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange.shade100, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.pin_drop),
                        ),
                        onTap: () {
                          _getCurrentLocation();
                          _addPinAtLocation(
                            _currentPosition.latitude,
                            _currentPosition.longitude,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ]),
            )),

            // Show zoom buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: Colors.blue.shade100, // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.add),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color: Colors.blue.shade100, // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.remove),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Show the place input fields & button for
            // showing the route
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Go Places',
                            style: GoogleFonts.montserrat(
                              fontSize: regularTextSize,
                              color: regularTextSizeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Start',
                              hint: 'Choose starting point',
                              prefixIcon: Icon(Icons.looks_one),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.my_location),
                                onPressed: () {
                                  _getCurrentLocation();
                                  _getAddress();
                                  startAddressController.text = _currentAddress;
                                  _startAddress = _currentAddress;
                                },
                              ),
                              controller: startAddressController,
                              focusNode: startAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _startAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Destination',
                              hint: 'Choose destination',
                              prefixIcon: Icon(Icons.looks_two),
                              controller: destinationAddressController,
                              focusNode: desrinationAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  searchMapMarkers(value);
                                });
                              }),
                          Column(
                            children: [
                              StreamBuilder<List<MarkerData>>(
                                stream: mapMarkersStreamController.stream,
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<MarkerData>> snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  if (!snapshot.hasData) {
                                    return Text('Loading...');
                                  }
                                  final List<MarkerData> mapMarkers =
                                      snapshot.data!;

                                  return Visibility(
                                      visible: _selectedMarkerName == null &&
                                              desrinationAddressFocusNode
                                                  .hasPrimaryFocus
                                          ? true
                                          : false,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: mapMarkers.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final MarkerData mapMarker =
                                              mapMarkers[index];
                                          return ListTile(
                                            title: Text(mapMarker.title),
                                            textColor: regularTextSizeColor,
                                            onTap: () {
                                              // Navigate to the map marker details screen
                                              setState(() {
                                                _destinationLatitude =
                                                    mapMarker.latitude;
                                                _destinationLongitude =
                                                    mapMarker.longitude;
                                                _selectedMarkerName =
                                                    mapMarker.title;
                                                destinationAddressController
                                                    .text = mapMarker.title;
                                                _destinationAddress =
                                                    mapMarker.address;
                                              });
                                            },
                                          );
                                        },
                                      ));
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: (_startAddress != '' &&
                                    _destinationAddress != '')
                                ? () async {
                                    startAddressFocusNode.unfocus();
                                    desrinationAddressFocusNode.unfocus();

                                    _calculateDistance().then((isCalculated) {
                                      if (isCalculated) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Distance Calculated Sucessfully'),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error Calculating Distance'),
                                          ),
                                        );
                                      }
                                    });
                                  }
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Show Route'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
