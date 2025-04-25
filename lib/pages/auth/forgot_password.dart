import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrol_track_mobile/components/background_auth.dart';
import 'package:patrol_track_mobile/components/button.dart';

class ForgotPass extends StatefulWidget {
  final String title;
  final String subtitle;

  const ForgotPass({
    Key? key,
    this.title = "Lupa Password",
    this.subtitle = "Masukkan email, kami akan mengirim kode verifikasi.",
  }) : super(key: key);

  @override
  _ForgotPass createState() => _ForgotPass();
}

class _ForgotPass extends State<ForgotPass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        title: widget.title,
        subtitle: widget.subtitle,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(225, 255, 255, .3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            MyButton(
              text: "Send Code",
              onPressed: () => Get.toNamed('/otp'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Text("Kembali ke menu Login",
                    style: GoogleFonts.poppins(
                        color: Colors.grey, 
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
