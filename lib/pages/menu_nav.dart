import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrol_track_mobile/pages/history_presence.dart';
import 'report/history_report.dart';
import 'setting.dart';
import 'home/home.dart';

class MenuNav extends StatefulWidget {
  @override
  _MenuNavState createState() => _MenuNavState();
}

class _MenuNavState extends State<MenuNav> {
  int currentTab = 0;
  final List<Widget> screens = [
    Home(),
    HistoryPresencePage(),
    HistoryReport(),
    Setting(),
  ];
  Widget currentScreen = Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentScreen,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt_outlined),
        backgroundColor: Color(0xFF1E3B57),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        onPressed: ()=> Get.toNamed('/report'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomAppBar(
          color: Colors.white,
          shape: CircularNotchedRectangle(),
          notchMargin: 10,
          child: Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _buildTabItem(0, Icons.home, 'Beranda'),
                _buildTabItem(1, Icons.assignment, 'Presensi'),
                SizedBox(width: 40),
                _buildTabItem(2, Icons.history, 'Histori Laporan'),
                _buildTabItem(3, Icons.person, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String text) {
    return GestureDetector(
      onTap: () => _updateTab(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: currentTab == index ? Color(0xFF356899) : Color(0xFF353840),
            ),
          SizedBox(height: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: currentTab == index ? Color(0xFF356899) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _updateTab(int index) {
    setState(() {
      currentScreen = screens[index];
      currentTab = index;
    });
  }
}
