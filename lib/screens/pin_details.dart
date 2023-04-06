import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class MarkerDetailsScreen extends StatelessWidget {
  final MarkerId markerId;
  final String markerName;
  final LatLng markerPosition;
  final String markerAddress;

  MarkerDetailsScreen({
    required this.markerId,
    required this.markerName,
    required this.markerPosition,
    required this.markerAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(markerName),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: markerPosition,
          zoom: 15,
        ),
        markers: Set<Marker>.of([
          Marker(
            markerId: markerId,
            position: markerPosition,
            infoWindow: InfoWindow(title: markerName, snippet: markerAddress),
          ),
        ]),
      ),
    );
  }
}