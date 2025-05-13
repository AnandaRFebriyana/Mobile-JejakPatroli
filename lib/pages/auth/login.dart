import 'package:flutter/material.dart';
import 'package:patrol_track_mobile/components/background_auth.dart';
import 'package:patrol_track_mobile/components/button.dart';
import 'package:patrol_track_mobile/components/textfield_auth.dart';
import 'package:patrol_track_mobile/core/controllers/auth_controller.dart';

class Login extends StatefulWidget {
  final String title;
  final String subtitle;

  const Login({
    Key? key,
    this.title = "Selamat Datang",
    this.subtitle = "Silahkan log in, untuk melanjutkan!",
  }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isObscure = true;
  bool _isLoading = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String? emailError;
  String? passwordError;


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
                  MyTextField(
                    controller: email,
                    labelText: "Email",
                    errorText: emailError,
                  ),
                  MyTextField(
                    controller: password,
                    labelText: "Password",
                    isPassword: true,
                    isObscure: _isObscure,
                    toggleObscureText: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                    errorText: passwordError,
                  ),
                ],
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: <Widget>[
            //     GestureDetector(
            //       onTap: () => Get.toNamed('/forgot-pass'),
            //       child: Text(
            //         "Forgot Password?",
            //         style: GoogleFonts.poppins(color: Colors.grey),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20),
            MyButton(
              text: "Masuk",
              onPressed: () async {
                setState(() {
                  emailError = email.text.isEmpty ? 'Email wajib diisi' : null;
                  passwordError = password.text.isEmpty ? 'Password wajib diisi' : null;
                });

                if (emailError == null && passwordError == null) {
                  setState(() {
                    _isLoading = true;
                  });
                  
                  await AuthController.login(context, email, password);

                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}
