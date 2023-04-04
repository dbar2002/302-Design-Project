import 'package:avandra/screens/edit_profile.dart';
import 'package:avandra/screens/home.dart';
import 'package:avandra/screens/pin_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/markers.dart';
import '../utils/colors.dart';
import '../utils/fonts.dart';
import '../widgets/basic_button.dart';

class UserProfPage extends StatefulWidget {
  @override
  _UserProfPageState createState() => _UserProfPageState();
}

enum MenuAction { logout, editProf, addNewOrg }

class _UserProfPageState extends State<UserProfPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
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
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/Login', (route) => false);
                  }
                  break;
                case MenuAction.editProf:
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/editProf', (route) => false);
                  break;
                case MenuAction.addNewOrg:
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/addNewOrg', (route) => false);
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
                PopupMenuItem<MenuAction>(
                    value: MenuAction.editProf, child: Text('Edit Profile')),
                PopupMenuItem<MenuAction>(
                  value: MenuAction.addNewOrg,
                  child: Text('Add New Organiztion'),
                ),
              ];
            },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Username
            Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final username = snapshot.data!['username'];
                  return Text(
                    username,
                    style: GoogleFonts.montserrat(
                      fontSize: 30,
                      color: regularTextSizeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),

            TabBar(
              controller: _tabController,
              indicatorColor: buttonColor,
              tabs: [
                Tab(
                  child: Text(
                    'Your Organizations',
                    style: GoogleFonts.montserrat(
                      fontSize: smallerTextSize,
                      color: regularTextSizeColor,
                    ),
                  ),
                  icon: Icon(
                    Icons.group,
                    color: Colors.black,
                  ),
                ),
                Tab(
                  child: Text(
                    'Your Pins',
                    style: GoogleFonts.montserrat(
                      fontSize: smallerTextSize,
                      color: regularTextSizeColor,
                    ),
                  ),
                  icon: Icon(
                    Icons.location_pin,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            // Organizations
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final organizations =
                      snapshot.data!['organizations'] as Map<dynamic, dynamic>;
                  final organizationNames = organizations.keys.toList();
                  return TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      // Organization List
                      ListView.builder(
                        itemCount: organizationNames.length,
                        itemBuilder: (context, index) {
                          final orgName = organizationNames[index];
                          return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => HomeScreen()));
                              },
                              child: ListTile(
                                title: Text(
                                  orgName,
                                  style: GoogleFonts.montserrat(
                                    fontSize: regularTextSize,
                                    color: regularTextSizeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'You are a: ${organizations[orgName]}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: smallerTextSize,
                                    color: regularTextSizeColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ));
                        },
                      ),
                      Expanded(
                        child:
                            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .collection('pins')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final markers = snapshot.data!.docs.map((doc) {
                              final data = doc.data();
                              return MarkerData(
                                  data['latitude'],
                                  data['longitude'],
                                  data['title'],
                                  data['address']);
                            }).toList();
                            return ListView.builder(
                              itemCount: markers.length,
                              itemBuilder: (context, index) {
                                final marker = markers[index];
                                final markerId = MarkerId(marker.title);
                                final googleMarker = Marker(
                                  markerId: markerId,
                                  position:
                                      LatLng(marker.latitude, marker.longitude),
                                  infoWindow: InfoWindow(
                                      title: marker.title,
                                      snippet: marker.address),
                                );
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MarkerDetailsScreen(
                                          markerId: markerId,
                                          markerName: marker.title,
                                          markerPosition: LatLng(
                                              marker.latitude,
                                              marker.longitude),
                                          markerAddress: marker.address,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    title: Text(marker.title,
                                        style: GoogleFonts.montserrat(
                                          fontSize: titleSize,
                                          color: regularTextSizeColor,
                                        )),
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
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}
