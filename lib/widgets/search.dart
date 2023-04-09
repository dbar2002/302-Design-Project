import '../utils/colors.dart';
import '../utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class searchField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final double width;
  final Icon prefixIcon;
  final Widget? suffixIcon;
  final Function(String) locationCallback;
  const searchField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.width,
    required this.prefixIcon,
    required this.suffixIcon,
    required this.locationCallback,
  }) : super(key: key);

  @override
  State<searchField> createState() => _searchField();
}

class _searchField extends State<searchField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width * 0.8,
      child: TextFormField(
        style: GoogleFonts.montserrat(
          fontSize: regularTextSize,
          color: regularTextSizeColor,
        ),
        onChanged: (value) {
          widget.locationCallback(value);
        },
        controller: widget.controller,
        focusNode: widget.focusNode,
        decoration: new InputDecoration(
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          labelText: widget.label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: widget.hint,
          hintStyle: GoogleFonts.montserrat(
            fontSize: smallerTextSize,
            color: smallerTextColor,
          ),
        ),
      ),
    );
  }
}
