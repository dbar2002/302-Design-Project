import 'package:avandra/widgets/input_box.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  String? person;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _organizationController.dispose();
  }

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
        body: SafeArea(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 60,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            AssetImage('lib/assets/images/logo.jpg'),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Sign Up Today!',
                      style: GoogleFonts.montserrat(
                        color: headingSizeColor,
                        fontSize: headingSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 38.0, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          //PUT A PICTURE HERE SOMEHOW

                          Column(
                            children: [
                              InputBox(
                                hintText: 'Enter your username',
                                title: TextInputType.text,
                                textEditingController: _usernameController,
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              InputBox(
                                hintText: 'Enter your email',
                                title: TextInputType.emailAddress,
                                textEditingController: _emailController,
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              InputBox(
                                hintText: 'Enter your password',
                                title: TextInputType.text,
                                textEditingController: _passwordController,
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              InputBox(
                                hintText: 'Organization',
                                title: TextInputType.text,
                                textEditingController: _organizationController,
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RadioListTile(
                          title: Text(
                            "Administration",
                            style: GoogleFonts.montserrat(
                              fontSize: regularTextSize,
                              color: regularTextSizeColor,
                            ),
                          ),
                          value: "Administration",
                          groupValue: person,
                          activeColor: buttonColor,
                          onChanged: (value) {
                            setState(() {
                              person = value.toString();
                            });
                          },
                        ),
                        RadioListTile(
                          title: Text("Visitor",
                              style: GoogleFonts.montserrat(
                                fontSize: regularTextSize,
                                color: regularTextSizeColor,
                              )),
                          value: "Visitor",
                          groupValue: person,
                          activeColor: buttonColor,
                          onChanged: (value) {
                            setState(() {
                              person = value.toString();
                            });
                          },
                        ),
                        RadioListTile(
                          title: Text("Employee",
                              style: GoogleFonts.montserrat(
                                fontSize: regularTextSize,
                                color: regularTextSizeColor,
                              )),
                          value: "Employee",
                          groupValue: person,
                          activeColor: buttonColor,
                          onChanged: (value) {
                            setState(() {
                              person = value.toString();
                            });
                          },
                        ),
                        RadioListTile(
                          title: Text("Student",
                              style: GoogleFonts.montserrat(
                                fontSize: regularTextSize,
                                color: regularTextSizeColor,
                              )),
                          value: "Student",
                          groupValue: person,
                          activeColor: buttonColor,
                          onChanged: (value) {
                            setState(() {
                              person = value.toString();
                            });
                          },
                        )
                      ],
                    ),
                    BasicButton(
                      text: 'Sign Up',
                      onPressed: () async {
                        bool res =
                            true; //await _authMethods.signInWithGoogle(context);
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
                  ])),
        ));
  }
}
