import 'dart:async';
import 'dart:math';

import 'package:avandra/screens/pin_details.dart';
import 'package:avandra/utils/colors.dart';
import 'package:avandra/widgets/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geofence_service/geofence_service.dart' as fence;
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:map_launcher/map_launcher.dart' as mapLauch;

import '../model/markers.dart';
import '../resources/notification_service.dart';
import '../resources/secrets.dart';
import '../utils/fonts.dart';

class allNavScreen extends StatefulWidget {
  const allNavScreen({Key? key}) : super(key: key);

  @override
  State<allNavScreen> createState() => _allNavScreenState();
}

class _allNavScreenState extends State<allNavScreen>
    with SingleTickerProviderStateMixin {
  //Firebase Stuff
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  //Maps Stuff
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  late GoogleMapController mapController;

  //Current Location Stuff
  late Position _currentPosition;
  String _currentAddress = '';

  //Start Position Stuff
  final startAddressController = TextEditingController();
  final startAddressFocusNode = FocusNode();
  String _startAddress = '';
  String currentOutput = "---";

  //Destination Position Stuff
  final destinationAddressController = TextEditingController();
  final desrinationAddressFocusNode = FocusNode();
  late double _destinationLatitude;
  late double _destinationLongitude;
  String _destinationAddress = '';

  //Stuff having to do with markers and such
  String? _selectedMarkerName;
  Set<Marker> markers = {};
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //Stuff for searching UI
  late AnimationController _animationController;
  late Animation<double> _animation;

  //Stuff for actuall searching
  final StreamController<List<MarkerData>> mapMarkersStreamController =
      StreamController<List<MarkerData>>.broadcast();
  final TextEditingController _searchController = TextEditingController();

  //Polylines
  String? _placeDistance;
  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  bool distanceCalced = false;
  final notificationService = NotificationService();

  //Geofencing
  final _activityStreamController = StreamController<fence.Activity>();
  final _geofenceStreamController = StreamController<fence.Geofence>();
  // Create a [Geofence] list.
  final _geofenceList = <fence.Geofence>[];

  // Create a [GeofenceService] instance and set options.
  final _geofenceService = fence.GeofenceService.instance.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: false,
      printDevLog: false,
      geofenceRadiusSortType: fence.GeofenceRadiusSortType.DESC);

  // This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(
      fence.Geofence geofence,
      fence.GeofenceRadius geofenceRadius,
      fence.GeofenceStatus geofenceStatus,
      fence.Location location) async {
    _geofenceStreamController.sink.add(geofence);
    double distanceInMeters = _coordinateDistance(
      location.latitude,
      location.longitude,
      geofence.latitude,
      geofence.longitude,
    );
    print(distanceInMeters);
    if (distanceInMeters <= 1.524) {
      // send a notification
      await notificationService.showNotification(
        title: 'You have arrived!',
        body: 'Welcome!',
      );
      _geofenceList.clear();
    } else if (distanceInMeters <= 3.048) {
      // 10 feet = 3.048 meters
      await notificationService.showNotification(
        title: 'Nearly There',
        body: '10 feet left',
      );
    }
  }

  // This function is to be called when the activity has changed.
  void _onActivityChanged(
      fence.Activity prevActivity, fence.Activity currActivity) {
    print('prevActivity: ${prevActivity.toJson()}');
    print('currActivity: ${currActivity.toJson()}');
    _activityStreamController.sink.add(currActivity);
  }

  // This function is to be called when the location has changed.
  void _onLocationChanged(fence.Location location) {
    print('location: ${location.toJson()}');
  }

  // This function is to be called when a location services status change occurs
  // since the service was started.
  void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

  // This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = fence.getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }

  void _addGeofence() async {
    // get the user's current location
    final currentPosition = await _getCurrentLocation();

    // create the geofence
    final geofence = fence.Geofence(
      id: 'place_2',
      latitude: _destinationLatitude,
      longitude: _destinationLongitude,
      radius: [
        fence.GeofenceRadius(id: 'radius_2m', length: 2),
      ],
    );

    // add the geofence to the list and to the service
    _geofenceList.add(geofence);
    _geofenceService.addGeofence(geofence);

    // show a success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Geofence added.'),
      duration: Duration(seconds: 2),
    ));
  }

  void _removeGeofenceById(String geofenceId) {
    int index =
        _geofenceList.indexWhere((geofence) => geofence.id == geofenceId);
    if (index != -1) {
      _geofenceList.removeAt(index);
      _geofenceService.start(_geofenceList).catchError(_onError);
    }
  }

  //init state for the whole app
  @override
  void initState() {
    access();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geofenceService
          .addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      _geofenceService.addLocationChangeListener(_onLocationChanged);
      _geofenceService.addLocationServicesStatusChangeListener(
          _onLocationServicesStatusChanged);
      _geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start(_geofenceList).catchError(_onError);
    });
    _getCurrentLocation();
    _getAddress();
    _getMarkersFromFirestore();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    super.initState();
  }

  @override
  void dispose() {
    destinationAddressController.dispose();
    startAddressController.dispose();
    _activityStreamController.close();
    _geofenceStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        minHeight: 200.0,
        parallaxEnabled: true,
        parallaxOffset: 0.5,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
        panelBuilder: (ScrollController sc) => _buildScrollableSheet(sc),
        body: _buildMap(),
      ),
    );
  }

  //Location Stuff
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

  //Everything PINS PINS PINS PINS
  Future<String> _getPinAddress(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks.first;
    return '${placemark.name}, ${placemark.locality}';
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

  //Everything regarding USER DATA
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

//FIX ME FIX ME FIX ME

  Future<void> addReportPin(MarkerData marker) {
    CollectionReference pinsCollection =
        FirebaseFirestore.instance.collection("Reports");

    String markerId =
        '($_currentPosition.latitude, $_currentPosition.longitude)';
    Marker reportMarker = Marker(
      markerId: MarkerId(markerId),
      position: LatLng(_currentPosition.latitude, _currentPosition.longitude),
      onTap: () => _onMarkerTapped(MarkerId(markerId)),
      infoWindow: InfoWindow(
        title: 'Start $markerId',
        snippet: _startAddress,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );
    markers.add(reportMarker);
    return pinsCollection.add({
      'latitude': marker.latitude,
      'longitude': marker.longitude,
      'title': marker.title,
      'address': marker.address,
    });
  }

  void _onMarkerTapped(MarkerId markerId) {
    Marker marker =
        markers.where((marker) => marker.markerId == markerId).first;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Report'),
          content: Text(
              'Are you sure you want to delete this report? It will remove it for all users.'),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                await deleteReport(markerId);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteReport(MarkerId markerId) async {
    Marker marker =
        markers.where((marker) => marker.markerId == markerId).first;
    final collectionRef = FirebaseFirestore.instance.collection('Reports');
    final query = collectionRef
        .where('latitude', isEqualTo: marker.position.latitude)
        .where('longitude', isEqualTo: marker.position.longitude);
    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      // Delete the document from Firestore
      final docId = snapshot.docs[0].id;
      await collectionRef.doc(docId).delete();
    }
    // Update the state to remove the marker from the map
    setState(() {
      markers.removeWhere((marker) => marker.markerId == markerId);
    });
  }

  void createReport(double latitude, double longitude) async {
    LatLng position = LatLng(latitude, longitude);
    int _selectedReport = 0;
    String? reportName;
    String address = await _getPinAddress(position);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report an Issue'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(children: <Widget>[
                RadioListTile(
                  value: 1,
                  title: Text("General Hazard"),
                  groupValue: _selectedReport,
                  activeColor: Colors.green,
                  onChanged: (val) {
                    setState(() {
                      reportName = "General Hazard";
                      _selectedReport = val!;
                    });
                  },
                ),
                RadioListTile(
                  value: 2,
                  title: Text("Weather"),
                  groupValue: _selectedReport,
                  activeColor: Colors.green,
                  onChanged: (val) {
                    setState(() {
                      reportName = "Weather";
                      _selectedReport = val!;
                    });
                  },
                ),
                RadioListTile(
                  value: 3,
                  title: Text("Traffic"),
                  groupValue: _selectedReport,
                  activeColor: Colors.green,
                  onChanged: (val) {
                    setState(() {
                      reportName = "Traffic";
                      _selectedReport = val!;
                    });
                  },
                ),
                RadioListTile(
                  value: 4,
                  title: Text("Event"),
                  groupValue: _selectedReport,
                  activeColor: Colors.green,
                  onChanged: (val) {
                    setState(() {
                      reportName = "Event";
                      _selectedReport = val!;
                    });
                  },
                ),
                RadioListTile(
                  value: 5,
                  title: Text("Suspicious Person"),
                  groupValue: _selectedReport,
                  activeColor: Colors.green,
                  onChanged: (val) {
                    setState(() {
                      reportName = "Suspicious Person";
                      _selectedReport = val!;
                    });
                  },
                ),
                RadioListTile(
                  value: 6,
                  title: Text("Other"),
                  groupValue: _selectedReport,
                  activeColor: Colors.green,
                  onChanged: (val) {
                    setState(() {
                      reportName = "Other";
                      _selectedReport = val!;
                    });
                  },
                ),
              ]);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('REPORT'),
              onPressed: () async {
                MarkerData markerData =
                    MarkerData(latitude, longitude, reportName!, address);
                await addReportPin(markerData);
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Report Created!'),
                      content: Text('You have successfully created a report'),
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

  void _getMarkersFromFirestore() async {
    final CollectionReference markersCollection =
        FirebaseFirestore.instance.collection('Reports');
    final QuerySnapshot querySnapshot = await markersCollection.get();

    setState(() {
      markers = querySnapshot.docs.map((doc) {
        final title = doc.get('title');
        final address = doc.get('address');
        final latitude = doc.get('latitude');
        final longitude = doc.get('longitude');
        String markerId = '($latitude, $longitude';
        final marker = Marker(
          markerId: MarkerId(markerId),
          onTap: () => _onMarkerTapped(MarkerId(markerId)),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: title, snippet: address),
        );
        return marker;
      }).toSet();
    });
  }

  //For the scrolling panel
  Widget _buildScrollableSheet(ScrollController scrollController) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.0),
          topRight: Radius.circular(18.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.all(16.0),
        children: [
          Text(
            'Travel With Ease',
            style: GoogleFonts.montserrat(
              fontSize: regularTextSize,
              color: regularTextSizeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .collection('pins')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final markers = snapshot.data!.docs.map((doc) {
                  final data = doc.data();
                  return MarkerData(data['latitude'], data['longitude'],
                      data['title'], data['address']);
                }).toList();
                return Container(
                  height: 50.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: scrollController,
                    itemCount: markers.length,
                    itemBuilder: (context, index) {
                      final marker = markers[index];
                      final markerId = MarkerId(marker.title);
                      final googleMarker = Marker(
                        markerId: markerId,
                        position: LatLng(marker.latitude, marker.longitude),
                        infoWindow: InfoWindow(
                            title: marker.title, snippet: marker.address),
                      );
                      return GestureDetector(
                        onTap: () {
                          // Navigate to the map marker details screen
                          setState(() {
                            _destinationLatitude = marker.latitude;
                            _destinationLongitude = marker.longitude;
                            _selectedMarkerName = marker.title;
                            destinationAddressController.text = marker.title;
                            _destinationAddress = marker.address;
                          });
                        },
                        child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.pin_drop,
                                  color: Colors.black,
                                ),
                                Text(
                                  marker.title,
                                  style: GoogleFonts.montserrat(
                                    fontSize: titleSize,
                                    color: regularTextSizeColor,
                                  ),
                                ),
                              ],
                            )),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.0),
          searchField(
              controller: startAddressController,
              focusNode: startAddressFocusNode,
              label: "Start",
              hint: "Choose Your Starting Point",
              width: width,
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
              locationCallback: (String value) {
                setState(() {
                  _startAddress = value;
                });
              }),
          SizedBox(height: 10),
          searchField(
              controller: destinationAddressController,
              focusNode: desrinationAddressFocusNode,
              label: "Destination",
              hint: "Choose Your Destination",
              width: width,
              prefixIcon: Icon(Icons.looks_two),
              suffixIcon: Icon(Icons.map),
              locationCallback: (String value) {
                setState(() {
                  searchMapMarkers(value);
                });
              }),
          SizedBox(height: 10),
          Visibility(
            visible: _placeDistance == null ? false : true,
            child: Text(
              'DISTANCE: $_placeDistance km',
              style: GoogleFonts.montserrat(
                fontSize: regularTextSize,
                color: regularTextSizeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: (_startAddress != '' && _destinationAddress != '')
                ? () async {
                    startAddressFocusNode.unfocus();
                    desrinationAddressFocusNode.unfocus();

                    setState(() {
                      if (markers.isNotEmpty) markers.clear();
                      if (polylines.isNotEmpty) polylines.clear();
                      if (polylineCoordinates.isNotEmpty)
                        polylineCoordinates.clear();
                      _placeDistance = null;
                    });

                    _calculateDistance().then((isCalculated) {
                      if (isCalculated) {
                        distanceCalced = true;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Distance Calculated Sucessfully'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error Calculating Distance'),
                          ),
                        );
                      }
                    });
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Calculate Distance'.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: (_startAddress != '' &&
                    _destinationAddress != '' &&
                    distanceCalced != false)
                ? () async {
                    startAddressFocusNode.unfocus();
                    desrinationAddressFocusNode.unfocus();

                    setState(() {
                      distanceCalced = false;
                      _placeDistance = null;
                    });

                    launch().then((isCalculated) {
                      if (isCalculated) {
                        distanceCalced = true;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Launched Sucessfully'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error Launching'),
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
              primary: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Results',
            style: GoogleFonts.montserrat(
              fontSize: regularTextSize,
              color: regularTextSizeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                  final List<MarkerData> mapMarkers = snapshot.data!;

                  return Visibility(
                      visible: _selectedMarkerName == null &&
                              desrinationAddressFocusNode.hasPrimaryFocus
                          ? true
                          : false,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: mapMarkers.length,
                        itemBuilder: (BuildContext context, int index) {
                          final MarkerData mapMarker = mapMarkers[index];
                          return ListTile(
                            title: Text(mapMarker.title),
                            textColor: regularTextSizeColor,
                            onTap: () {
                              // Navigate to the map marker details screen
                              setState(() {
                                _destinationLatitude = mapMarker.latitude;
                                _destinationLongitude = mapMarker.longitude;
                                _selectedMarkerName = mapMarker.title;
                                destinationAddressController.text =
                                    mapMarker.title;
                                _destinationAddress = mapMarker.address;
                              });
                            },
                          );
                        },
                      ));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    //Sizing purposes
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
        height: height,
        width: width,
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: <Widget>[
              GoogleMap(
                onTap: (latLng) {
                  _onMapTapped(latLng);
                },
                markers: Set<Marker>.from(markers),
                initialCameraPosition: _initialLocation,
                myLocationEnabled: true,
                mapType: MapType.normal,
                zoomGesturesEnabled: true,
                polylines: Set<Polyline>.of(polylines.values),
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                trafficEnabled: true,
                indoorViewEnabled: true,
                myLocationButtonEnabled: false,
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
                        color: buttonColor, // button color
                        child: InkWell(
                          splashColor: buttonColor, // inkwell color
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(Icons.menu),
                          ),
                          onTap: () => Navigator.of(context)
                              .pushNamedAndRemoveUntil(
                                  '/Menu', (route) => false),
                        ),
                      ),
                    ),
                  ),
                ]),
              )),
              // Show zoom buttons
              SafeArea(
                  child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ClipOval(
                        child: Material(
                          color: buttonColor, // button color
                          child: InkWell(
                            splashColor: buttonColor, // inkwell color
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
                      SizedBox(height: 20),
                      ClipOval(
                        child: Material(
                          color: buttonColor, // button color
                          child: InkWell(
                            splashColor: Colors.redAccent, // inkwell color
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: Icon(Icons.access_alarm),
                            ),
                            onTap: () {
                              _getCurrentLocation();
                              createReport(
                                _currentPosition.latitude,
                                _currentPosition.longitude,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ClipOval(
                        child: Material(
                          color: buttonColor, // button color
                          child: InkWell(
                            splashColor: buttonColor, // inkwell color
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
                    ],
                  ),
                ),
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
                          color: buttonColor, // button color
                          child: InkWell(
                            splashColor: buttonColor, // inkwell color
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
            ],
          ),
        ));
  }

  //Search functionality
  void searchMapMarkers(String searchQuery) async {
    searchQuery = searchQuery.toUpperCase();
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

  //For navigation
  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      // _getCurrentLocation();
      //List<Location> startPlacemark = await locationFromAddress(_startAddress);

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      /*double startLatitude = _startAddress == _currentAddress
          ? _currentPosition.latitude
          : startPlacemark[0].latitude;

      double startLongitude = _startAddress == _currentAddress
          ? _currentPosition.longitude
          : startPlacemark[0].longitude;
          */
      double startLatitude = _currentPosition.latitude;

      double startLongitude = _currentPosition.longitude;

      print(startLatitude);
      print(startLongitude);

      double destinationLatitude = _destinationLatitude;
      double destinationLongitude = _destinationLongitude;
      print(_destinationLatitude);
      print(_destinationLongitude);

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

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      setState(() {
        _placeDistance = totalDistance.toStringAsFixed(2);
        print('DISTANCE: $_placeDistance km');
      });
/*
       */
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> launch() async {
    final availableMaps = await mapLauch.MapLauncher.installedMaps;
    double startLatitude = _currentPosition.latitude;

    double startLongitude = _currentPosition.longitude;

    print(startLatitude);
    print(startLongitude);

    double destinationLatitude = _destinationLatitude;
    double destinationLongitude = _destinationLongitude;
    print(availableMaps);
    _addGeofence();
    await availableMaps.first.showDirections(
        destination:
            mapLauch.Coords(_destinationLatitude, _destinationLongitude),
        originTitle: "My Location",
        origin: /* mapLauch.Coords(
              _currentPosition.latitude, _currentPosition.longitude)*/
            mapLauch.Coords(startLatitude, startLongitude),
        directionsMode: mapLauch.DirectionsMode.walking);
    return true;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }
}
