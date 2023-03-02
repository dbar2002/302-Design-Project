import 'package:avandra/widgets/input_box.dart';
import 'package:flutter/services.dart';

import '../utils/colors.dart';
import '../utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
              CircleAvatar(
                backgroundColor: Colors.black,
                radius: 60,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('lib/assets/images/logo1.jpg'),
                ),
              ),
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

                    Column(
                      children: [
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
                        BasicButton(
                          text: 'Sign In',
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
                              "Don't have an account? ",
                              style: GoogleFonts.montserrat(
                                fontSize: regularTextSize,
                                color: regularTextSizeColor,
                              ),
                            ),
                            TextButton(onPressed: () async {Navigator.pushNamed(context, '/SignUp');}, 
                            child:  Text(
                              "Create An Account",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: regularTextSize,
                                color: regularTextSizeColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),)
                           
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
