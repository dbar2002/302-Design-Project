import '../utils/colors.dart';
import '../utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputBox extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool obscureText;
  final String hintText;
  final TextInputType title;
  const InputBox({
    Key? key,
    required this.textEditingController,
    this.obscureText = false,
    required this.hintText,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
            style: GoogleFonts.montserrat(
              fontSize: regularTextSize,
              color: regularTextSizeColor,
            ),
            controller: textEditingController,
            decoration: InputDecoration(
              hintStyle: GoogleFonts.montserrat(
                fontSize: regularTextSize,
                color: smallerTextColor,
              ),
              hintText: hintText,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)),
              filled: true,
              contentPadding: const EdgeInsets.all(8),
            ),
            keyboardType: title,
            obscureText: obscureText),
      ],
    );
  }
}
