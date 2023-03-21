import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.black,
      radius: 60,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage('lib/assets/images/logo1.jpg'),
      ),
    );
  }
}
