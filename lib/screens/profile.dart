import 'package:avandra/screens/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  final double coverHeight = 100;
  final double profileHeight = 100;
  String username = "Jane Doe";
  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
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
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          buildTop(),
          buildContent(),
          // TODO: figure out the right height for this thing
          Divider(height: screenHeight - coverHeight - (profileHeight / 2)),
          buildBottom(),
        ],
      ),
    );
  }

  /* this widget creates the top background of the profile page */
  Widget buildTop() {
    // final top = coverHeight - profileHeight / 2;
    final bottom = profileHeight / 4;

    return Center(
        // Stack lets you overlap things
        child: Stack(
      clipBehavior: Clip.none,

      // all widgets in children will be overlapped because they're in the
      // Stack Widget
      children: [
        // this creates the backgroundImage
        Container(
          // margin: EdgeInsets.only(bottom: 0),
          child: buildCoverImage(Alignment.center),
        ),

        // this creates the profile image
        Container(
          alignment: Alignment.bottomCenter,
          child: buildProfileImage(),
        ),

        // this text button creates a route to the edit profile page
        Container(
          alignment: Alignment.topRight,
          child: TextButton(
            style: TextButton.styleFrom(
                textStyle: const TextStyle(
                    fontSize: regularTextSize, color: Colors.black)),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditProfilePage(),
              ));
            },
            child: const Text("Edit Profile"),
          ),
        ),
      ],
    ));
  }

  /* this widget creates the profile name, city, and saved pins */
  Widget buildContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // const SizedBox(height: 8),
        Divider(height: 10),
        Text(
          // this will need to be updated from the edit profile page
          username,
          style:
              TextStyle(fontSize: regularTextSize, color: regularTextSizeColor),
        ),
        const SizedBox(height: 8),
        Text(
          'San Francisco',
          style:
              TextStyle(fontSize: regularTextSize, color: regularTextSizeColor),
        ),

        Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: "My Pins"),
                Tab(text: "My Organizations"),
              ],
            )),

// TODO: once pins and organizations are set up, sync them here
        Container(
          padding: const EdgeInsets.only(left: 20),
          child: TabBarView(controller: _tabController, children: [
            // this will hold all the saved pins
            ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Text("Physics Class"),
                Text("Global Christianity"),
                Text("Circuits"),
                Text("English class"),
                Text("FYE class"),
              ],
            ),

            // this will hold all the organizations
            ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Text("California Baptist University"),
                Text("University of California Riverside"),
                Text("Riverside Public Library"),
                Text("University of California Irvine"),
                Text("Colorado Christian University"),
              ],
            ),
          ]),
        ),

        // const SizedBox(height: 16),

        // This is my attempt to make the My Pins button open to the saved pins
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     DefaultTabController(
        //         length: 2,
        //         child: Scaffold(
        //           resizeToAvoidBottomInset: true,
        //           appBar: AppBar(
        //             bottom: TabBar(
        //               tabs: [
        //                 Tab(icon: Icon(Icons.pin)),
        //                 Tab(icon: Icon(Icons.house)),
        //               ],
        //             ),
        //           ),
        //           body: TabBarView(
        //             children: [
        //               Text("Pin 1 of many"),
        //               Text("Organization 1 of many")
        //               // creates the organizations
        //               // DefaultTabController(
        //               //     length: organizations.length,
        //               //     child: Scaffold(
        //               //         appBar: AppBar(
        //               //             bottom: TabBar(isScrollable: true, tabs: [
        //               //       Tab(text: organizations[0]),
        //               //       Tab(text: organizations[1]),
        //               //       Tab(text: organizations[2]),
        //               //     ])))),
        //             ],
        //           ),
        //         )),
        //   ],
        // ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SavedPin(),
          ],
        ),
        // const SizedBox(height: 16),
        Divider(),
        // const SizedBox(height: 16),
        // TO DO: create buildPins function
        // buildPins(),
        // const SizedBox(height: 32),
      ],
    );
  }

  Widget buildBottom() {
    return Container(
      child: buildCoverImage(Alignment.bottomCenter),
    );
  }

  /* this widget build the cover image */
  Widget buildCoverImage(Alignment pos) => Container(
        color: backgroundColor,
        alignment: pos,
        child: Container(
          height: coverHeight,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("lib/assets/images/natureBackground.jpg"),
                fit: BoxFit.fitWidth),
          ),
        ),
      );

  /* this widget builds the profile iamge */
  Widget buildProfileImage() => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.white,
        backgroundImage:
            AssetImage("lib/assets/images/influencer_profile_pic.jpeg"),
      );
}

/* this class creates the user's saved pins */
class SavedPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSavedPin(text: 'Physics class'),
          _buildDivider(),
          _buildSavedPin(text: 'Circuits'),
          _buildDivider(),
          _buildSavedPin(text: 'Global Christianity'),
        ],
      );

  /* this widget creates the spaces between pins */
  Widget _buildDivider() => SizedBox(
        height: 24,
        child: VerticalDivider(),
      );

  /* this widget creates the saved pins themselves */
  Widget _buildSavedPin({
    required String text,
  }) =>
      MaterialButton(
          padding: EdgeInsets.symmetric(vertical: 4),
          onPressed: () {},
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10),
                Text(
                  text,
                  style: TextStyle(
                      fontSize: regularTextSize, color: regularTextSizeColor),
                ),
              ]));
}

// class PinsAction extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     return PinsActionApp();
//   }
// }

// class PinsActionApp extends State<PinsAction> {
//   int i = 0;
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         for(var i = 0; i < pins.length; i++) {
//           Text(pins[i])
//         }
//       ]
//       while (i < pins.length()) {
//         data: pins[i];
//       }
//     );
//   }
// }
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
