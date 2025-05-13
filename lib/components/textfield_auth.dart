import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final bool isObscure;
  final VoidCallback? toggleObscureText;
  final String? errorText;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.isPassword = false,
    this.isObscure = false,
    this.toggleObscureText,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscure : false,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey,
            fontSize: 14,
          ),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: toggleObscureText,
                )
              : null,
        ),
      ),
    );
  }
}
