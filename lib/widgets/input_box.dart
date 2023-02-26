import '../utils/colors.dart';
import '../utils/fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputBox extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool obscureText;
  final String hintText;
  final TextInputType title;
  final String? Function(String?) validator;
  final bool suffixIcon;
  final bool? isDense;
  const InputBox({
    Key? key,
    required this.textEditingController,
    required this.validator,
    required this.hintText,
    this.suffixIcon = false,
    this.isDense,
    this.obscureText = true,
    required this.title,
  }) : super(key: key);

  @override
  State<InputBox> createState() => _InputBox();
}

class _InputBox extends State<InputBox> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
            style: GoogleFonts.montserrat(
              fontSize: regularTextSize,
              color: regularTextSizeColor,
            ),
            controller: widget.textEditingController,
            decoration: InputDecoration(
              hintStyle: GoogleFonts.montserrat(
                fontSize: regularTextSize,
                color: smallerTextColor,
              ),
              hintText: widget.hintText,
              suffixIcon: widget.suffixIcon
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.remove_red_eye
                            : Icons.visibility_off_outlined,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
              suffixIconConstraints: (widget.isDense != null)
                  ? const BoxConstraints(maxHeight: 33)
                  : null,
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
            keyboardType: widget.title,
            obscureText: (widget.obscureText && _obscureText)),
      ],
    );
  }
}
