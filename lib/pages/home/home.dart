import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:patrol_track_mobile/components/history_card.dart';
import 'package:patrol_track_mobile/components/alert_quick.dart';
import 'package:patrol_track_mobile/core/controllers/attendance_controller.dart';
import 'package:patrol_track_mobile/core/controllers/report_controller.dart';
import 'package:patrol_track_mobile/core/controllers/schedule_controller.dart';
import 'package:patrol_track_mobile/core/models/attendance.dart';
import 'package:patrol_track_mobile/core/models/schedule.dart';
import 'package:patrol_track_mobile/core/models/user.dart';
import 'package:patrol_track_mobile/core/services/attendance_service.dart';
import 'package:patrol_track_mobile/core/services/auth_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:patrol_track_mobile/controllers/location_controller.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late User user = User(id: 0, name: '', email: '');
  Attendance? attendance;
  DateTime today = DateTime.now();
  late Future<bool> _todayReportFuture;
  late Future<List<Attendance>> _attendanceFuture;
  late Future<List<Schedule>> _scheduleFuture;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchToday();
    _refreshData();
    
    // Set up periodic refresh every 1 minute
    _refreshTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        _refreshData();
        fetchToday(); // Also refresh attendance data
      }
    });
  }

  void _refreshData() {
    setState(() {
      _todayReportFuture = ReportController.checkTodayReport(context);
      _attendanceFuture = AttendanceController.getAttendanceHistory(context);
      _scheduleFuture = ScheduleController.getSchedules(context);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchUser() async {
    try {
      User getUser = await AuthService.getUser();
      if (mounted) {
        setState(() {
          user = getUser;
        });
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  Future<void> fetchToday() async {
    try {
      Attendance? getToday = await AttendanceService.getToday();
      if (mounted) {
        setState(() {
          attendance = getToday;
        });
      }
    } catch (e) {
      print('Error fetching today: $e');
    }
  }

  Future<void> _saveCheckOut() async {
    try {
      final currentAttendance = await AttendanceService.getToday();

      if (currentAttendance == null) {
        MyQuickAlert.info(context, 'Presensi belum tersedia!');
        return;
      }

      if (currentAttendance.checkOut != currentAttendance.endTime) {
        MyQuickAlert.info(context, 'Belum saatnya untuk pulang!');
        return;
      }

      if (currentAttendance.checkOut != null) {
        MyQuickAlert.info(context, 'Anda telah membuat presensi!');
        return;
      }

      int id = currentAttendance.id;
      await AttendanceController.saveCheckOut(
        context,
        id: id,
        checkOut: TimeOfDay.now(),
      );
      
      fetchToday();
      
      print("Attendance ID: $id || berhasil check out.");
    } catch (error) {
      print('Gagal untuk check out: $error');
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "--:--";
    
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat('HH:mm');
    return format.format(dt);
  }

  Future<File> compressImage(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));
    img.Image resizedImage = img.copyResize(image!, width: 800);
    List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 50);

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File compressedFile =
        File('$tempPath/compressed_${imageFile.path.split('/').last}')
          ..writeAsBytesSync(compressedBytes);

    return compressedFile;
  }

  void _pickImage(BuildContext context) async {
    try {
      final currentAttendance = await AttendanceService.getToday();

      if (currentAttendance == null) {
        MyQuickAlert.info(context, 'Presensi belum tersedia!');
        return;
      }

      if (currentAttendance.checkIn != null) {
        // User has already checked in - just inform them
        // No need to redirect to map screen as location tracking runs in background
        MyQuickAlert.info(context, 'Anda sudah melakukan check-in hari ini.');
        return;
      }

      final picker = ImagePicker();
      print('Opening camera...');
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,  // Reduce quality to ensure smaller file size
        maxWidth: 1024,    // Limit max dimensions
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        print('Photo captured: ${pickedFile.path}');
        File image = File(pickedFile.path);
        
        print('Original photo size: ${image.lengthSync()} bytes');
        print('Original photo exists: ${image.existsSync()}');

        if (image.lengthSync() > 2048 * 1024) {
          print('Compressing photo...');
          image = await compressImage(image);
          print('Compressed photo size: ${image.lengthSync()} bytes');
          print('Compressed photo exists: ${image.existsSync()}');
        }
        
        int id = currentAttendance.id;
        print("Navigating to presensi with ID: $id and photo: ${image.path}");

        await Get.toNamed('/presensi', arguments: {'id': id, 'image': image});
        
        fetchToday();
      } else {
        print('No photo was captured.');
        MyQuickAlert.info(context, 'Foto diperlukan untuk presensi!');
      }
    } catch (e) {
      print('Error in _pickImage: $e');
      MyQuickAlert.error(context, 'Gagal mengambil foto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _headerHome(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hari ini",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/permission'),
                      child: Text(
                        "Ajukan permohonan izin",
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  twoCard(
                    () => _pickImage(context),
                    "Check In",
                    attendance?.checkIn != null 
                        ? _formatTime(attendance!.checkIn)
                        : attendance?.startTime != null 
                            ? _formatTime(attendance!.startTime)
                            : "--:--",
                    attendance?.checkIn != null 
                        ? attendance!.getEffectiveStatus() == "Terlambat" ? "Terlambat" : "Hadir" 
                        : "Pergi Bekerja",
                    attendance?.checkIn != null 
                        ? attendance!.getEffectiveStatus() == "Terlambat" ? Colors.orange : Colors.green
                        : Colors.black,
                    FontAwesomeIcons.signIn,
                  ),
                  twoCard(
                    () => _saveCheckOut(),
                    "Check Out",
                    attendance?.checkOut != null 
                        ? _formatTime(attendance!.checkOut)
                        : attendance?.endTime != null 
                            ? _formatTime(attendance!.endTime)
                            : "--:--",
                    attendance?.checkOut != null ? "Selesai" : "Pulang",
                    attendance?.checkOut != null ? Colors.green : Colors.black,
                    FontAwesomeIcons.signOut,
                  ),
                ],
              ),
              FutureBuilder<bool>(
                future: _todayReportFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    // Check if tracking is active
                    final locationController = Get.find<LocationController>();
                    if (locationController.isTracking.value) {
                      return _buildPatrolCard(
                        title: 'Anda sedang dalam patroli',
                        icon: Icons.location_on,
                        color: Colors.green,
                      );
                    } else if (snapshot.data == false) {
                      return _buildPatrolCard(
                        title: 'Kamu belum patroli hari ini.',
                        icon: Icons.warning,
                        color: Colors.red,
                      );
                    } else {
                      return SizedBox();
                    }
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Jadwal",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/history-presence'),
                      child: Text(
                        "Lihat Semua",
                        style: GoogleFonts.poppins(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          FutureBuilder<List<Schedule>>(
            future: _scheduleFuture,
            builder: (context, snapshot) {
              print('Schedule FutureBuilder state: ${snapshot.connectionState}');
              if (snapshot.hasError) {
                print('Schedule error: ${snapshot.error}');
              }
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                print('No schedule data available');
                return const Center(
                  child: Text('Jadwal belum tersedia.'),
                );
              } else {
                List<Schedule> schedules = snapshot.data!;
                print('Loaded ${schedules.length} schedules');
                List<Widget> cards = [];
                int limit = 5;
                int counter = 0;

                for (var schedule in schedules) {
                  if (counter >= limit) break;
                  
                  cards.add(
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color(0xFF3085FE).withOpacity(0.1),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.calendarWeek,
                                color: Color(0xFF305E8B),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  schedule.day,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "${schedule.startTime} - ${schedule.endTime}",
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  counter++;
                }

                return Expanded(
                  child: ListView(
                    children: cards,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _headerHome() {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 15, right: 15, bottom: 5),
      decoration: const BoxDecoration(
        color: Color(0xFF356899),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 3, bottom: 2),
                  child: Text(
                    "Selamat Datang",
                    style: GoogleFonts.poppins(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                      wordSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3, bottom: 70),
                  child: Text('${user.name}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      wordSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
  margin: const EdgeInsets.only(left: 10),
  width: 50,
  height: 50,
  decoration: const BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.grey,
  ),
  child: ClipOval(
    child: user.photo != null && user.photo!.isNotEmpty
        ? Image.network(
            'http://jejakpatroli.my.id/storage/${user.photo}',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Gagal load gambar: $error');
              return Image.asset(
                'assets/images/user_profile.jpeg',
                fit: BoxFit.cover,
              );
            },
          )
        : Image.asset(
            'assets/images/user_profile.jpeg',
            fit: BoxFit.cover,
          ),
  ),
),
        ],
      ),
    );
  }

  Widget twoCard(Function() onTap, String title, String time, String subtitle, Color textColor, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 165,
        height: 134,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        child: Icon(icon),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        title,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textColor,
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

  Widget _buildPatrolCard(
      {String title = '',
      IconData icon = Icons.error,
      Color color = Colors.black}) {
    return Card(
      margin: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
