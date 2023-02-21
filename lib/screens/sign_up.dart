import 'package:avandra/widgets/input_box.dart';
import 'package:flutter/services.dart';

import '../utils/colors.dart';
import '../utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/basic_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundColor,

        //Back Button
        appBar: AppBar(
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor: backgroundColor,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                size: 25,
                color: Colors.black,
              )),
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'Sign Up Today!',
            style: GoogleFonts.montserrat(
              color: headingSizeColor,
              fontSize: headingSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 38.0, horizontal: 20),
            child: Column(
              children: [
                InputBox(title: "Name", obscureText: true),
                InputBox(title: "Email", obscureText: true),
                InputBox(title: "Password", obscureText: true),
                InputBox(title: "Organization", obscureText: true),
              ],
            ),
          ),
          BasicButton(
            text: 'Sign Up',
            onPressed: () async {
              bool res = true; //await _authMethods.signInWithGoogle(context);
              if (res) {
                Navigator.pushNamed(context, '/confirmation');
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account? ",
                style: GoogleFonts.montserrat(
                  fontSize: regularTextSize,
                  color: regularTextSizeColor,
                ),
              ),
              Text(
                "Login",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: regularTextSize,
                  color: regularTextSizeColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ]));
  }
}
