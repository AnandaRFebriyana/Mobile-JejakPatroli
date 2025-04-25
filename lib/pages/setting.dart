import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:patrol_track_mobile/components/button.dart';
import 'package:patrol_track_mobile/components/header.dart';
import 'package:patrol_track_mobile/core/controllers/auth_controller.dart';
import 'package:patrol_track_mobile/core/models/user.dart';
import 'package:patrol_track_mobile/core/services/auth_service.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  late User user = User(name: '', email: '');

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      User getUser = await AuthService.getUser();
      setState(() {
        user = getUser;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(title: "Profil"),
          const SizedBox(height: 20),
          Expanded(
            child: _buildSetting(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSetting(BuildContext context) {
    final TextEditingController name = TextEditingController(text: user.name);
    final TextEditingController email = TextEditingController(text: user.email);
    final TextEditingController birthDate = TextEditingController(text: user.birthDate != null ? DateFormat('dd MMMM yyyy').format(DateTime.parse(user.birthDate!)) : '');
    final TextEditingController address = TextEditingController(text: user.address ?? '');
    final TextEditingController phoneNumber = TextEditingController(text: user.phoneNumber ?? '');

    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: user.photo != null && user.photo!.isNotEmpty
                    ? NetworkImage('https://patroltrack.my.id/storage/${user.photo}')
                    : const AssetImage('assets/images/user_profile.jpeg') as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),
              buildTextField(name, Icons.person),
              const SizedBox(height: 10),
              buildTextField(email, Icons.email_outlined),
              const SizedBox(height: 10),
              buildTextField(birthDate, Icons.calendar_month_outlined),
              const SizedBox(height: 10),
              buildTextField(phoneNumber, Icons.phone_enabled_outlined),
              const SizedBox(height: 10),
              buildTextField(address, Icons.home, maxLines: 2),
              const SizedBox(height: 30),
              MyButton(
                text: "Keluar",
                onPressed: () {
                  AuthController.logout(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTextField(TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              icon,
              color: Colors.grey,
              size: 20,
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black,
              ),
              maxLines: maxLines,
              readOnly: true,
            ),
          ),
        ],
      ),
    );
  }
}
