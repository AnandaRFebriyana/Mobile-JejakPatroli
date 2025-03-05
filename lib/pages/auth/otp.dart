import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patrol_track_mobile/components/button.dart';
import '../../components/background_auth.dart';

class Otp extends StatefulWidget {
  final String title;
  final String subtitle;

  const Otp({
    Key? key,
    this.title = "Verify Code",
    this.subtitle =
        "Enter your verification  code from your email that we’ve sent.",
  }) : super(key: key);

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _otpControllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                        decoration: const InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            MyButton(
              text: "Verify",
              onPressed: () => Get.toNamed('/reset-pass'),
            ),
          ],
        ),
      ),
    );
  }
}
