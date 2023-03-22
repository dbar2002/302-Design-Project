import 'package:avandra/screens/menu.dart';
import 'package:avandra/screens/navigation_page.dart';
import 'package:avandra/screens/select_map.dart';
import 'package:avandra/screens/sign_up.dart';
import 'package:avandra/widgets/input_box.dart';
import 'package:avandra/widgets/sign_up_header.dart';
import 'package:flutter/services.dart';

import '../resources/authentication.dart';
import '../resources/validator.dart';
import '../utils/colors.dart';
import '../utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/util.dart';
import '../widgets/basic_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required String title}) : super(key: key);

  @override
  State<LoginScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? selectedValue;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  bool _isLoading = false;

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
        email: _emailController.text, password: _passwordController.text);
    if (res == 'success') {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SelectMapScreen(),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SignUpHeaderWidget(title: "Sign In!", subtitle: "Get Mapping!"),
              const SizedBox(height: 25),
              Text(
                'Welcome to Avandra!',
                style: GoogleFonts.montserrat(
                  color: headingSizeColor,
                  fontSize: headingSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 38.0, horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //PUT A PICTURE HERE SOMEHOW

                      Column(
                        children: [
                          InputBox(
                              hintText: 'Enter your email',
                              title: TextInputType.emailAddress,
                              textEditingController: _emailController,
                              validator: (value) => Validator.validateEmail(
                                    email: value,
                                  )),
                          const SizedBox(
                            height: 24,
                          ),
                          InputBox(
                            hintText: 'Enter your password',
                            title: TextInputType.text,
                            textEditingController: _passwordController,
                            validator: (value) => Validator.validatePassword(
                              password: value,
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          BasicButton(
                            text: 'Sign In',
                            onPressed: () async {
                              loginUser();
                            },
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Don't have an account? ",
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
                                              const SignUpScreen()))
                                },
                                child: Text(
                                  "Create An Account",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: regularTextSize,
                                    color: regularTextSizeColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
