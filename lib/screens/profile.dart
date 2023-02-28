import 'package:avandra/screens/edit_profile.dart';
import 'package:flutter/material.dart';
import '../utils/fonts.dart';
import '../utils/colors.dart';
import '../utils/global.dart';

class ProfilePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final double coverHeight = 100;
  final double profileHeight = 100;
  String username = "Jane Doe";

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
          onPressed: () {},
        ),
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
