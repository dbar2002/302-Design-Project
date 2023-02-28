import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Container(
          height: height / 3,
          width: width / 3,
          child: const Image(
            image: AssetImage('lib/assets/images/logo1.jpg'),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
