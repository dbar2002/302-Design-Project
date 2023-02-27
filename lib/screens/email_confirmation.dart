import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:avandra/screens/add_new_org.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/fonts.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();

}


class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool? isEmailVerified = false;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified;
    if(!isEmailVerified!) {
      sendEmail();

      timer = Timer.periodic(
        Duration (seconds: 3), 
        (_) => checkVerification(),
      );
    }
  }
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  Future checkVerification() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
  }
Future sendEmail() async {
    try {final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification();
    } catch (e) {
      e.toString();
    }
    if (isEmailVerified!) {
      timer?.cancel();
  }  
}

  @override
  Widget build(BuildContext context) => isEmailVerified!
  ? AddNewOrg() //placeholder page for now can be replaced with our main homepage later
    : Scaffold(
        body: Padding (padding: EdgeInsets.all(45),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('A verification email has been sent to your email',
                  style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: regularTextSize,
                            color: regularTextSizeColor,
                         ),
                  textAlign: TextAlign.center,
                  
                  ),
                  TextButton(onPressed: sendEmail, child: Text('Didnt receive an email? Click here',
                  style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: regularTextSize,
                            color: regularTextSizeColor,
                            decoration: TextDecoration.underline,),
                  textAlign: TextAlign.center,
                  ),
                  ) 
                ],
                )
              ),
            );
}