import 'package:avandra/widgets/input_box.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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
  final List<String> items = [
    'Administration',
    'Visitor',
    'Student',
    'Employee',
  ];
  String? selectedValue;

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
                            AssetImage('lib/assets/images/logo1.jpg'),
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
                              Text(
                                'Select who you are:',
                                style: GoogleFonts.montserrat(
                                  color: headingSizeColor,
                                  fontSize: regularTextSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Center(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    isExpanded: true,
                                    hint: Row(
                                      children: const [
                                        Icon(
                                          Icons.list,
                                          size: 16,
                                          color: regularTextSizeColor,
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Select Type',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: regularTextSizeColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    items: items
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: regularTextSizeColor,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ))
                                        .toList(),
                                    value: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = value as String;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward_ios_outlined,
                                    ),
                                    iconSize: 14,
                                    iconEnabledColor: regularTextSizeColor,
                                    iconDisabledColor: Colors.grey,
                                    buttonHeight: 50,
                                    buttonWidth: 160,
                                    buttonPadding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    buttonDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.black26,
                                      ),
                                      color: Colors.white,
                                    ),
                                    buttonElevation: 2,
                                    itemHeight: 40,
                                    itemPadding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    dropdownMaxHeight: 200,
                                    dropdownWidth: 200,
                                    dropdownPadding: null,
                                    dropdownDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: smallerTextColor,
                                    ),
                                    dropdownElevation: 8,
                                    scrollbarRadius: const Radius.circular(40),
                                    scrollbarThickness: 6,
                                    scrollbarAlwaysShow: true,
                                    offset: const Offset(-20, 0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
