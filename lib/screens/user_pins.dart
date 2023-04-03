import 'package:avandra/screens/pin_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/markers.dart';
import '../utils/colors.dart';

class UserMarkersScreen extends StatelessWidget {
  UserMarkersScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Your Saved Locations"),
        backgroundColor: buttonColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pushNamed('/Menu');
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
          return ListView.builder(
            itemCount: markers.length,
            itemBuilder: (context, index) {
              final marker = markers[index];
              final markerId = MarkerId(marker.title);
              final googleMarker = Marker(
                markerId: markerId,
                position: LatLng(marker.latitude, marker.longitude),
                infoWindow:
                    InfoWindow(title: marker.title, snippet: marker.address),
              );
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MarkerDetailsScreen(
                        markerId: markerId,
                        markerName: marker.title,
                        markerPosition:
                            LatLng(marker.latitude, marker.longitude),
                        markerAddress: marker.address,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(marker.title),
                  subtitle: Text(marker.address),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
