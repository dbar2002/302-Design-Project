import 'package:avandra/screens/profile.dart';
import 'package:avandra/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:avandra/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

import '../resources/validator.dart';
import '../utils/fonts.dart';
import '../widgets/back_button.dart';
import '../widgets/input_box.dart';

//FIXME
var username;

var password;

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
  final usernameController = TextEditingController(text: username);
  final userPasswordController = TextEditingController(text: password);
  bool showPassword = false;

  @override
  void dispose() {
    // cleans up the controller when the widget is disposed
    usernameController.dispose();
    userPasswordController.dispose();
    super.dispose;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // this creates the small navbar on the top of the page
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: BackButtonWidget(),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),

        // this lets you focus on each text box
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
            InputBox(
              obscureText: false,
              hintText: 'Enter new username',
              title: TextInputType.text,
              textEditingController: usernameController,
              validator: (value) => Validator.validateName(
                name: value,
              ),
            ),

            SizedBox(
              height: 10,
            ),

            InputBox(
              obscureText: true,
              hintText: 'Enter new password',
              title: TextInputType.text,
              textEditingController: userPasswordController,
              validator: (value) => Validator.validatePassword(
                password: value,
              ),
              suffixIcon: true,
            ),

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
                  onPressed: () async {
                    bool updated = true;
                    if (updated) {
                      // this updates each global variable to the current text
                      username = usernameController.text;
                      password = userPasswordController.text;

                      // when update is pushed, it sends the user back to the profile page
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(
                        fontSize: directionInstructionSize,
                        letterSpacing: 2.2,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget buildTextField(
      String labelText,
      String value,
      bool isPasswordTextField,
      TextEditingController userController,
      String hintText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextFormField(
        controller: userController,
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintStyle: GoogleFonts.montserrat(
            fontSize: regularTextSize,
            color: smallerTextColor,
          ),
          hintText: hintText,
          // toggles the password as seen or hidden
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
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black,
            ),
          ),

          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: regularTextSize,
            color: regularTextSizeColor,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }
}
