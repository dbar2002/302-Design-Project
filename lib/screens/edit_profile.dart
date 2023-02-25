import 'package:avandra/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:avandra/utils/colors.dart';

import '../utils/fonts.dart';
import '../utils/global.dart';

class SettingUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Setting UI',
      home: EditProfilePage(),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // this creates the small navbad\r on the top of the page
      appBar: AppBar(
        backgroundColor: buttonColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            // figure out how to make this the buttonColor
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(
              MaterialPageRoute(
                builder: (context) => ProfilePage(),
              ),
            );
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(children: [
            Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: titleSizeColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(
              height: 15,
            ),

            Center(
              child: Stack(children: [
                Container(
                    width: 130,
                    height: 130,

                    // this creates the white circle behind the profile pic
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 4,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1),
                              offset: Offset(0, 10))
                        ],

                        // this creates the profile pic
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                              "lib/assets/images/influencer_profile_pic.jpeg"),
                        ))),
                Positioned(
                    bottom: 0,
                    right: 0,

                    // this Container creates the edit pencil icon
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 4,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                        color: buttonColor,
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.black,
                      ),
                    ))
              ]),
            ),

            SizedBox(
              height: 35,
            ),

            // this is for all text fields
            buildTextField("Username", "Jane Doe", false),
            buildTextField("Email", "janedoe@gmail.com", false),
            buildTextField("Phone Number", "+1478238899", false),
            buildTextField("Password", "mypassword", true),
            // SizedBox(
            //   height: 5,
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // this creates the Update button at the bottom of the screen
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    elevation: 2,
                    padding: EdgeInsets.symmetric(horizontal: 50),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Update",
                    style: TextStyle(
                        fontSize: directionInstructionSize,
                        letterSpacing: 2.2,
                        color: Colors.white),
                  ),
                ),
              ],
            )
          ]),
        ),
      ),
    );
  }

  Widget buildTextField(
      String labelText, String placeholder, bool isPasswordTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
          suffixIcon: isPasswordTextField
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.grey,
                  ),
                )
              : null,
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintText: placeholder,
          hintStyle: TextStyle(
            fontSize: regularTextSize,
            fontWeight: FontWeight.w300,
            color: regularTextSizeColor,
          ),
        ),
      ),
    );
  }
}
