import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Header extends StatelessWidget {
  final String title;
  final bool backButton;

  const Header({Key? key, required this.title, this.backButton = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 15, right: 15, bottom: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF356899),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          if (backButton)
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
            color: Colors.white,
          ),
          Container(
            padding: const EdgeInsets.only(top: 40, left: 15, right: 15, bottom: 10),
          ),
          Text(title, style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
