import 'package:flutter/material.dart';
import '../utils/fonts.dart';

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
      ],
    );
  }

  /* this widget creates the profile name, city, and saved pins */
  Widget buildContent() => Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Calamity Jane',
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
              SavedPinWidget(),
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
  // TODO: no image shows up for whatever reason
  Widget buildCoverImage() => Container(
        color: Colors.grey,
        child: Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("..assets/images/natureBackground.jpg"),
                  fit: BoxFit.cover),
            )),

        // Image.network creates a widget that displays an image onscreen
        // child: Image.network(
        //   AssetImage('..assets/images/'),
        //   width: double.infinity,
        //   height: coverHeight,
        //   fit: BoxFit.cover,
        // ),
      );

  /* this widget builds the profile iamge */
  // TODO: no image shows up for the profile pic
  Widget buildProfileImage() => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey.shade800,
        backgroundImage: AssetImage('..assets/images/naturebackground.jpg'),
        // NetworkImage creates an object that provides an image from the URL
        // backgroundImage: NetworkImage(
        //   'https://www.google.com/imgres?imgurl=https%3A%2F%2Fwww.plannthat.com%2Fwp-content%2Fuploads%2F2018%2F11%2Finfluencer-instagram-business-profile.jpeg&imgrefurl=https%3A%2F%2Fwww.plannthat.com%2Fneed-an-instagram-business-profile%2F&tbnid=aEjzsqFGj0K0_M&vet=12ahUKEwjx7_m2uar9AhVjOkQIHSNtBuwQMygkegUIARCBAw..i&docid=FEt7mHXDB9ocyM&w=1920&h=1280&q=profile%20picture&hl=en&ved=2ahUKEwjx7_m2uar9AhVjOkQIHSNtBuwQMygkegUIARCBAw',
        // ),
      );
}

/* this class creates the user's saved pins */
class SavedPinWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildSavedPin(text: 'Physics class'),
          _buildDivider(),
          _buildSavedPin(text: 'Circuits'),
          _buildDivider(),
          _buildSavedPin(text: 'Global Christianity'),
        ],
      );

  /* this widget creates the spaces between pins */
  Widget _buildDivider() => Container(
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
