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
  final double coverHeight = 280;
  final double profileHeight = 144;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          buildTop(),
          buildContent(),
        ],
      ),
    );
  }

  /* this widget creates the top background of the profile page */
  Widget buildTop() {
    final top = coverHeight - profileHeight / 2;
    final bottom = profileHeight / 2;

    // Stack lets you overlap things
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      // all widgets in children will then be overalpped
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: buildCoverImage(),
        ),
        Positioned(
          top: top,
          child: buildProfileImage(),
        ),

        // this text button creates a route to the edit profile page
        Positioned(
          top: top,
          child: TextButton(
            style: TextButton.styleFrom(
                textStyle: const TextStyle(
                    fontSize: regularTextSize, color: Colors.white)),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditProfilePage(),
              ));
            },
            child: const Text("Edit Profile"),
          ),
        ),
      ],
    );
  }

  /* this widget creates the profile name, city, and saved pins */
  Widget buildContent() => Column(
        children: [
          const SizedBox(height: 8),
          Text(
            // this will need to be updated from the edit profile page
            username,
            style: TextStyle(
                fontSize: regularTextSize, color: regularTextSizeColor),
          ),
          const SizedBox(height: 8),
          Text(
            'San Francisco',
            style: TextStyle(
                fontSize: regularTextSize, color: regularTextSizeColor),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SavedPin(),
            ],
          ),
          const SizedBox(height: 16),
          Divider(),
          const SizedBox(height: 16),
          // TO DO: create buildPins function
          // buildPins(),
          const SizedBox(height: 32),
        ],
      );

  /* this widget build the cover image */
  Widget buildCoverImage() => Container(
        color: backgroundColor,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("lib/assets/images/natureBackground.jpg"),
                fit: BoxFit.cover),
          ),
        ),
      );

  /* this widget builds the profile iamge */
  Widget buildProfileImage() => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.white,
        // backgroundImage:
        //     AssetImage('assets/images/influnecer_profile_pic.jpeg'),
        // NetworkImage creates an object that provides an image from the URL
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
