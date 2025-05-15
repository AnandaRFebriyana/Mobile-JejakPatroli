import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

enum IconType {
  CheckIn,
  CheckOut,
  Patrol,
  Error
}

class MyCard extends StatelessWidget {
  final IconType icon;
  final String title;
  final String subtitle;
  final String time;
  final String status;

  MyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
  });

  IconData _getIcon() {
    switch (icon) {
      case IconType.CheckIn:
        return FontAwesomeIcons.signIn;
      case IconType.CheckOut:
        return FontAwesomeIcons.signOut;
      case IconType.Patrol:
        return FontAwesomeIcons.clock;
      case IconType.Error:
        return FontAwesomeIcons.bug;
    }
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'terlambat':
        return Colors.orange;
      case 'hadir':
        return Colors.green;
      case 'sakit':
      case 'izin':
        return Colors.blue;
      case 'alpha':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(5),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFF3085FE).withOpacity(0.1),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: const Color(0xFF305E8B),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}