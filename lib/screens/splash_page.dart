import 'package:avandra/screens/sign_in.dart';
import 'package:avandra/utils/colors.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(Duration(milliseconds: 2500), (){});
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          title: 'Avandra',
        )));
  }



  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: splashpageColor,
      body: Center(
        child: Container(
          height: height / 10,
          width: width - (width * 0.2),
          child: const Image(
            image: AssetImage('lib/assets/images/full_logo.jpg'),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
