import 'package:avandra/screens/sign_in.dart';
import 'package:avandra/widgets/input_box.dart';
import 'package:avandra/widgets/sign_up_header.dart';
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
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SignUpHeaderWidget(
                      title: 'Sign Up Today', subtitle: 'It\'s free'),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25.0, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            InputBox(
                                hintText: 'Enter your full name',
                                title: TextInputType.text,
                                textEditingController: _usernameController,
                                validator: (textValue) {
                                  if (textValue == null || textValue.isEmpty) {
                                    return 'Name field is required!';
                                  }
                                  return null;
                                }),
                            const SizedBox(
                              height: 24,
                            ),
                            InputBox(
                                hintText: 'Enter your email',
                                title: TextInputType.emailAddress,
                                textEditingController: _emailController,
                                isDense: true,
                                validator: (textValue) {
                                  if (textValue == null || textValue.isEmpty) {
                                    return 'Email is required!';
                                  }

                                  return null;
                                }),
                            const SizedBox(
                              height: 24,
                            ),
                            InputBox(
                              hintText: 'Enter your password',
                              title: TextInputType.text,
                              textEditingController: _passwordController,
                              
                              validator: (textValue) {
                                if (textValue == null || textValue.isEmpty) {
                                  return 'Password is required!';
                                }
                                return null;
                              },
                              suffixIcon: true,
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            InputBox(
                                hintText: 'Organization',
                                title: TextInputType.text,
                                textEditingController: _organizationController,
                                validator: (textValue) {
                                  if (textValue == null || textValue.isEmpty) {
                                    return 'An organization is required!';
                                  }

                                  return null;
                                }),
                            const SizedBox(
                              height: 24,
                            ),
                            Center(
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
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
                                            'Select Your Status',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: smallerTextColor,
                                              fontFamily: 'Proxima Nova',
                                            ),
                                            textAlign: TextAlign.left,
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
                                                  fontSize: 15,
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
                                      Icons.arrow_drop_down,
                                    ),
                                    iconSize: 15,
                                    iconEnabledColor: regularTextSizeColor,
                                    iconDisabledColor: Colors.grey,
                                    buttonHeight: 50,
                                    buttonWidth: 200,
                                    buttonPadding: const EdgeInsets.only(
                                        left: 8, right: 8, bottom: 0),
                                    buttonDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.black26,
                                      ),
                                      color: Colors.white,
                                    ),
                                    buttonElevation: 2,
                                    itemHeight: 40,
                                    itemPadding: const EdgeInsets.only(
                                        left: 8, right: 8, bottom: 0),
                                    dropdownMaxHeight: 200,
                                    dropdownWidth: 200,
                                    dropdownPadding:
                                        EdgeInsets.only(left: 8, right: 8),
                                    dropdownDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    dropdownElevation: 8,
                                    scrollbarRadius: const Radius.circular(30),
                                    scrollbarThickness: 4,
                                    scrollbarAlwaysShow: true,
                                    offset: const Offset(-20, 0),
                                  ),
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
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()))
                        },
                        child: Text("Login",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: regularTextSize,
                              color: regularTextSizeColor,
                              decoration: TextDecoration.underline,
                            )),
                      ),
                    ],
                  ),
                ])),
      ),
    ));
  }
}
