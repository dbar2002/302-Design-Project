import 'package:avandra/widgets/back_button.dart';
import 'package:avandra/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/fonts.dart';

class SignUpHeaderWidget extends StatelessWidget {
  const SignUpHeaderWidget({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final String title, subtitle;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //Back Button
        BackButtonWidget(),
        LogoWidget(),
        Text(
          title,
          style: GoogleFonts.montserrat(
            color: headingSizeColor,
            fontSize: headingSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.montserrat(
            color: smallerTextColor,
            fontSize: smallerTextSize,
          ),
        ),
      ],
    );
  }
}
