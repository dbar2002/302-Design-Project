

import 'package:avandra/screens/email_confirmation.dart';
import 'package:avandra/screens/home.dart';
import 'package:avandra/screens/sign_in.dart';
import 'package:avandra/utils/global.dart';
import 'package:avandra/widgets/input_box.dart';
import 'package:avandra/widgets/sign_up_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../resources/authentication.dart';
import '../resources/validator.dart';
import '../utils/colors.dart';
import '../utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/util.dart';
import '../widgets/basic_button.dart';
import '../widgets/firestore_search.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

Future<Map<String, dynamic>?> get currentUserClaims async {
  final user = FirebaseAuth.instance.currentUser;

  // If refresh is set to true, a refresh of the id token is forced.
  final idTokenResult = await user?.getIdTokenResult(true);

  return idTokenResult?.claims;
}

class _SignUpScreenState extends State<SignUpScreen> {
  var selectedOrg;
  final _registerFormKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();

  String role = 'visitor';

  bool _isLoading = false;
  String dropDownValue = "Select Organization";

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _organizationController.dispose();
  }

  late Map<String, String> orgAndRole = {_organizationController.text: role};

  final List<String> items = [
    'Visitor',
    'Student',
    'Employee',
  ];

  String? selectedValue;
  bool showDropdown = true;

  void signUpUser() async {
    // set loading to true
    setState(() {
      _isLoading = true;
    });

    // signup user using our authmethodds
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      organization: orgAndRole,
    );
    // if string returned is sucess, user has been created
    if (res == "success") {
      setState(() {
        _isLoading = false;
      });
      // navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const VerifyEmailScreen(),
        ),
      );

    } else {
      setState(() {
        _isLoading = false;
      });
      // show the error
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedValueSingleDialog = "Select an Organization";
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
                                obscureText: false,
                                hintText: 'Enter your full name',
                                title: TextInputType.text,
                                textEditingController: _usernameController,
                                validator: (value) => Validator.validateName(
                                      name: value,
                                    )),
                            const SizedBox(
                              height: 24,
                            ),
                            InputBox(
                                obscureText: false,
                                hintText: 'Enter your email',
                                title: TextInputType.emailAddress,
                                textEditingController: _emailController,
                                isDense: true,
                                validator: (value) => Validator.validateEmail(
                                      email: value,
                                    )),
                            const SizedBox(
                              height: 24,
                            ),
                            InputBox(
                              obscureText: true,
                              hintText: 'Enter your password',
                              title: TextInputType.text,
                              textEditingController: _passwordController,
                              validator: (value) => Validator.validatePassword(
                                password: value,
                              ),
                              suffixIcon: true,
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('organizations')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    const Text("Loading.....");
                                  } else {
                                    List<DropdownMenuItem> organizations = [];
                                    for (int i = 0;
                                        i <
                                            (snapshot.data! as dynamic)
                                                .docs
                                                .length;
                                        i++) {
                                      DocumentSnapshot snap =
                                          snapshot.data!.docs[i];
                                      organizations.add(
                                        DropdownMenuItem(
                                          child: Text(
                                            snap['name'],
                                            style: GoogleFonts.montserrat(
                                              fontSize: regularTextSize,
                                              color: regularTextSizeColor,
                                            ),
                                          ),
                                          value: "${snap['name']}",
                                        ),
                                      );
                                    }
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(width: 50.0),
                                        DropdownButton(
                                          iconDisabledColor: smallerTextColor,
                                          icon: Icon(Icons.arrow_drop_down,
                                              color: Colors.black54),
                                          dropdownColor: backgroundColor,
                                          items: organizations,
                                          onChanged: (orgValue) {
                                            _organizationController.text =
                                                orgValue;
                                            final snackBar = SnackBar(
                                              content: Text(
                                                  'Selected Organization is $orgValue',
                                                  style: GoogleFonts.montserrat(
                                                    fontSize: regularTextSize,
                                                    color: regularTextSizeColor,
                                                  )),
                                            );
                                            setState(() {
                                              selectedOrg = orgValue;
                                            });
                                          },
                                          value: selectedOrg,
                                          isExpanded: false,
                                          hint: new Text(
                                            "Choose Organization",
                                            style: GoogleFonts.montserrat(
                                              fontSize: regularTextSize,
                                              color: regularTextSizeColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return Container();
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  BasicButton(
                      text: 'Sign Up',
                      onPressed: () async {
                        signUpUser();
                      }),
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
                                  builder: (context) =>
                                      const LoginScreen(title: "")))
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
