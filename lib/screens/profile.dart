import 'package:avandra/screens/edit_profile.dart';
import 'package:avandra/widgets/basic_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/fonts.dart';
import '../utils/colors.dart';
import '../utils/global.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

enum MenuAction { logout }

// TickerProviderStateMixin is to allow the tabContoller to work
class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final double coverHeight = 150;
  final double profileHeight = 100;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String username = '';

  Future<void> _getUsername() async {
    // get's current user's name
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();
      username = snapshot.get('username');
    }
    ;
  }

  // TODO: connect the pins and organizations to user's stored ones
  List<String> pins = [
    "Physics Class",
    "Global Christianity",
    "Circuits",
    "English class",
    "FYE",
    "Engineering Statistics"
  ];
  List<String> organizations = [
    "California Baptist University",
    "University of California Riverside",
    "Riverside Public Library",
    "University of California Irvine",
  ];
  TabController? _tabController;
  ScrollController? _scrollController;

  // initState() must be included to activate the controllers
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    _getUsername();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

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
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                    value: MenuAction.logout, child: Text('Logout'))
              ];
            },
          )
        ],
      ),

      /*
       * Currently getting an excpetion for renderBox (don't know where)
       * output: navbar, then username (from Firebase!) and Edit Profile
       * button, but they are on opposite ends of the screen
       */

      // before: it was in a Stack widget
      body: Column(
        // for Column widget:
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        // this was for ListView, but it doesn't even render w/ ListView
        // physics: NeverScrollableScrollPhysics(),
        // padding: EdgeInsets.all(10),
        children: <Widget>[
          // FIXME: for some reason, the cover image is low down on the page

// container is supposed to vertically align the username & edit profile button
          Container(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // alignment: AlignmentDirectional.topCenter,
              children: [
                Text(
                  username,
                  style: GoogleFonts.montserrat(
                    fontSize: titleSize,
                    color: titleSizeColor,
                  ),
                ),

                // Positioned(
                // setting top and right to 0 positions the button to the top right
                // child:
                Flexible(
                  child: Container(
                    // alignment used for Container
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      style: TextButton.styleFrom(
                          textStyle: const TextStyle(
                              fontSize: regularTextSize, color: buttonColor)),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditProfilePage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // ),
              ],
            ),
          ),
          // buildTop(),
          _editProfile(),
          Divider(height: 15),
          buildContent(),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: BasicButton(
                  text: "Add New Organization",
                  onPressed: () async {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/addNewOrg', (route) => false);
                  })),

          // TODO: figure out the right height for this thing
          Divider(height: coverHeight),
          // buildBottom(),
        ],
      ),
    );
  }

  /* this widget creates the top background of the profile page */
  Widget buildTop() {
    return Center(
        // Stack lets you overlap things
        child: Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.center,

      // all widgets in children will be overlapped because they're in the
      // Stack Widget
      children: [
        // this creates the backgroundImage
        Positioned(
          top: 0,
          bottom: -20,
          child: Container(
            child: buildCoverImage(Alignment.center, coverHeight),
          ),
        ),

        // this creates the profile image
        // Positioned(
        //   // top: 0,
        //   child:
        Container(
          alignment: AlignmentDirectional.center,
          child: buildProfileImage(),
        ),
        // ),

        // this text button creates a route to the edit profile page
        Positioned(
          // setting top and right to 0 positions the button to the top right
          top: 0,
          right: 0,
          child: Container(
            alignment: AlignmentDirectional.topEnd,
            child: TextButton(
              style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                      fontSize: regularTextSize, color: buttonColor)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditProfilePage(),
                ));
              },
              child: const Text("Edit Profile",
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
          ),
        ),
      ],
    ));
  }

// this widget creates the edit profile page button
// TODO: make this button smaller (what the heck)
  Widget _editProfile() {
    return Positioned(
      top: 0,
      right: 0,
      width: 25,
      child: Container(
        padding: const EdgeInsets.all(5.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditProfilePage(),
            ));
          },
          style: ElevatedButton.styleFrom(
            primary: buttonColor,
            minimumSize: const Size(
              25,
              35,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: buttonColor),
            ),
          ),
          child: Text(
            'Edit Profile',
            style: GoogleFonts.montserrat(
              color: regularTextSizeColor,
              fontSize: regularTextSize,
            ),
          ),
        ),
      ),
    );

    // return BasicButton(
    //     text: 'Edit Profile',
    //     onPressed: () {
    //       Navigator.of(context).push(MaterialPageRoute(
    //         builder: (context) => EditProfilePage(),
    //       ));
    //     });
  }

  /* this widget creates the profile name, city, and saved pins */
  Widget buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Divider(height: 10),
        Text(
          // this will need to be updated from the edit profile page
          username,
          style: TextStyle(fontSize: titleSize, color: regularTextSizeColor),
        ),
        const SizedBox(height: 8),
        // Text(
        //   'San Francisco',
        //   style: TextStyle(fontSize: titleSize, color: regularTextSizeColor),
        // ),

        Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              indicatorColor: darkerNavigationColor,
              tabs: [
                Tab(
                    child: Text("My Pins",
                        style: TextStyle(
                          fontSize: regularTextSize,
                          color: regularTextSizeColor,
                        ))),
                Tab(
                    child: Text("My Organizations",
                        style: TextStyle(
                          fontSize: regularTextSize,
                          color: regularTextSizeColor,
                        ))),
              ],
            )),

        // Container(
        //     child: TabBarView(
        //   controller: _tabController,
        //   clipBehavior: Clip.hardEdge,
        //   children: [_buildTab('collection1'), _buildTab('collection2')],
        // )),

// TODO: once pins and organizations are set up, sync them here
        // Container(
        //   padding: const EdgeInsets.only(left: 20),
        //   height: regularTextSize + 3,
        //   child: TabBarView(
        //     controller: _tabController,
        //     clipBehavior: Clip.hardEdge,
        //     children: [
        //       Expanded(
        //           child: ListView.separated(
        //               scrollDirection: Axis.horizontal,
        //               controller: _scrollController,
        //               shrinkWrap: true,
        //               itemCount: pins.length,
        //               separatorBuilder: (BuildContext context, int index) {
        //                 return VerticalDivider(
        //                   width: 15.0,
        //                   // color: darkerNavigationColor,
        //                   // thickness: 2.0,
        //                 );
        //               },
        //               // ignore: non_constant_identifier_names
        //               itemBuilder: (BuildContext context, int index) {
        //                 return StreamBuilder<QuerySnapshot>(
        //                     stream: FirebaseFirestore.instance
        //                         .collection('organizations')
        //                         .snapshots(),
        //                     builder: (context, snapshot) {
        //                       if (!snapshot.hasData) {
        //                         return const Text("Loading...");
        //                       } else {
        //                         List<ListView> organizations = [];
        //                         for (int i = 0;
        //                             i < (snapshot.data! as dynamic).docs.length;
        //                             i++) {
        //                           DocumentSnapshot snap =
        //                               snapshot.data!.docs[i];
        //                           return Text("${snap['name']}",
        //                               style: GoogleFonts.montserrat(
        //                                 fontSize: regularTextSize,
        //                                 color: regularTextSizeColor,
        //                               ));
        //                         }
        //                       }
        //                     });
        //               })),
        // FAILED: I'm following the select map organizations drop down here
        // StreamBuilder<QuerySnapshot>(
        //   stream: FirebaseFirestore.instance
        //     .collection('organizations')
        //     .snapshots(),
        //   builder: (context, snapshot) {
        //     if (!snapshot.hasData) {
        //       const Text("Loading...");
        //     } else {
        //       List<ListView> organizations = [];
        //       for (int i = 0;
        //           i < (snapshot.data! as dynamic).docs.length;
        //           i++) {
        //             DocumentSnapshot snap = snapshot.data!.docs[i];;
        //             organizations.add(
        //                 ListView.builder()
        //                 child: Text(
        //                   snap['name'],
        //                   style: GoogleFonts.montserrat(
        //                     fontSize: regularTextSize,
        //                     color: regularTextSizeColor,
        //                   ),
        //                 ),
        //                 value: "${snap['name']}",

        //             );
        //           }
        //     }
        //   }
        // )
        // this will hold all the saved pins
        Expanded(
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: pins.length,
                separatorBuilder: (BuildContext context, int index) {
                  return VerticalDivider(
                    width: 15.0,
                    // color: darkerNavigationColor,
                    // thickness: 2.0,
                  );
                },
                // ignore: non_constant_identifier_names
                itemBuilder: (BuildContext context, int index) {
                  return Text(pins[index],
                      style: TextStyle(
                        fontSize: regularTextSize,
                        color: regularTextSizeColor,
                      ));
                })),

        // this holds all the organizations
        Expanded(
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: false,
                controller: _scrollController,
                itemCount: organizations.length,
                separatorBuilder: (BuildContext context, int index) {
                  return VerticalDivider(
                    width: 15.0,
                  );
                },
                // ignore: non_constant_identifier_names
                itemBuilder: (BuildContext context, int index) {
                  return Text(organizations[index],
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: regularTextSize,
                        color: regularTextSizeColor,
                      ));
                })),
      ],

      //   ),
      // ),
      // ],
    );
  }

  Widget _buildTab(String collectionName) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection(collectionName).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('Loading...');
          }

          final names = snapshot.data?.docs.map((doc) => doc['name']).toList();
          return ListView.builder(
            itemCount: names?.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(names?[index]),
              );
            },
          );
        });
  }

  Widget buildBottom() {
    return Container(
      child: buildCoverImage(Alignment.bottomCenter, coverHeight),
    );
  }

  /* this widget build the cover image */
  Widget buildCoverImage(Alignment pos, double givenHeight) => Container(
      color: backgroundColor,
      alignment: pos,
      child: Container(
        height: givenHeight,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/cover_image.png"),
            fit: BoxFit.fitWidth,
          ),
        ),
      ));

  /* this widget builds the profile iamge */
  Widget buildProfileImage() => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.white,
        backgroundImage:
            AssetImage("lib/assets/images/influencer_profile_pic.jpeg"),
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
