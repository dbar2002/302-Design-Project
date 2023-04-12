import 'package:avandra/screens/pin_details.dart';
import 'package:avandra/utils/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/markers.dart';
import '../utils/colors.dart';
import '../utils/fonts.dart';

class UserMarkersScreen extends StatelessWidget {
  UserMarkersScreen();

  @override
  Widget build(BuildContext context) {
    void _onMarkerLongPress(MarkerData marker) async {
      final value = await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(0, 0, 0, 0),
        items: [
          PopupMenuItem(
            value: 'edit',
            child: Text('Edit Pin'),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text('Delete Pin'),
          ),
        ],
      );

      if (value == 'edit') {
        showDialog(
            context: context,
            builder: (context) {
              String newTitle = marker.title;
              return AlertDialog(
                title: Text('Edit Pin'),
                content: TextField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                  onChanged: (value) => newTitle = value,
                  controller: TextEditingController(text: marker.title),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final collectionRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .collection('pins');
                      final query = collectionRef
                          .where('latitude', isEqualTo: marker.latitude)
                          .where('longitude', isEqualTo: marker.longitude);
                      final snapshot = await query.get();
                      if (snapshot.docs.isNotEmpty) {
                        // Update the document in Firestore
                        final docId = snapshot.docs[0].id;
                        await collectionRef.doc(docId).update({
                          'title': newTitle,
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Save'),
                  )
                ],
              );
            });
      } else if (value == 'delete') {
        // Find the document with the matching latitude and longitude values
        final collectionRef = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('pins');
        final query = collectionRef
            .where('latitude', isEqualTo: marker.latitude)
            .where('longitude', isEqualTo: marker.longitude);
        final snapshot = await query.get();

        if (snapshot.docs.isNotEmpty) {
          // Delete the document from Firestore
          final docId = snapshot.docs[0].id;
          await collectionRef.doc(docId).delete();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Pin deleted.'),
              action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () async {
                    collectionRef.add({
                      'latitude': marker.latitude,
                      'longitude': marker.longitude,
                      'title': marker.title,
                      'address': marker.address,
                    });
                  })));
        }
      }
    }

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
            final docID = doc.id;
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
                onLongPress: () {
                  _onMarkerLongPress(marker);
                },
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
                  titleTextStyle: GoogleFonts.montserrat(
                    fontSize: titleSize,
                    color: regularTextSizeColor,
                  ),
                  subtitle: Text(marker.address,
                      style: GoogleFonts.montserrat(
                        fontSize: regularTextSize,
                        color: regularTextSizeColor,
                      )),
                  trailing: Icon(
                    Icons.location_pin,
                    color: Colors.black,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
