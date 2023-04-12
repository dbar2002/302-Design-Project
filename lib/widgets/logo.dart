import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Color.fromRGBO(10, 61, 96, 1),
      radius: 60,
      child: CircleAvatar(
        radius: 55,
        backgroundImage: AssetImage('lib/assets/images/logo1.jpg'),
      ),
    );
  }
}
