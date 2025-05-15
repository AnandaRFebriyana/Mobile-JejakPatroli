import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patrol_track_mobile/components/header.dart';
import 'package:patrol_track_mobile/components/history_card.dart';
import 'package:patrol_track_mobile/core/controllers/attendance_controller.dart';
import 'package:patrol_track_mobile/core/models/attendance.dart';

class HistoryPresencePage extends StatefulWidget {
  const HistoryPresencePage({Key? key}) : super(key: key);

  @override
  _HistoryPresenceState createState() => _HistoryPresenceState();
}

class _HistoryPresenceState extends State<HistoryPresencePage> {
  late Future<List<Attendance>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = AttendanceController.getAttendanceHistory(context);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.Hm();
    return format.format(dt);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(title: "Histori Presensi"),
          Expanded(
            child: FutureBuilder<List<Attendance>>(
              future: _attendanceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data kehadiran histori yang tersedia.'),
                  );
                } else {
                  List<Attendance> attendances = snapshot.data!;
                  List<Widget> cards = [];
                  int limit = 10;
                  int counter = 0;

                  for (var attendance in attendances) {
                    if (counter >= limit) {
                      break;
                    }
                    if (attendance.checkIn != null) {
                      cards.add(
                        MyCard(
                          icon: IconType.CheckIn,
                          title: "Check In",
                          subtitle: DateFormat('dd-MM-yyyy').format(attendance.date),
                          time: _formatTime(attendance.checkIn!),
                          status: attendance.getEffectiveStatus(),
                        ),
                      );
                      counter++;
                    }
                    if (attendance.checkOut != null && counter < limit) {
                      cards.add(
                        MyCard(
                          icon: IconType.CheckOut,
                          title: "Check Out",
                          subtitle: DateFormat('dd-MM-yyyy').format(attendance.date),
                          time: _formatTime(attendance.checkOut!),
                          status: attendance.getEffectiveStatus(),
                        ),
                      );
                      counter++;
                    }
                  }
                  return ListView(
                    children: cards,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}