import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrol_track_mobile/components/header.dart';
import 'package:patrol_track_mobile/core/controllers/schedule_controller.dart';
import 'package:patrol_track_mobile/core/models/schedule.dart';

class SchedulePresence extends StatefulWidget {
  const SchedulePresence({Key? key}) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<SchedulePresence> {
  late Future<List<Schedule>> _futureSchedules;

  @override
  void initState() {
    super.initState();
    _futureSchedules = ScheduleController.getSchedules(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(title: "Jadwal", backButton: true),
          Expanded(
            child: FutureBuilder<List<Schedule>>(
              future: _futureSchedules,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<Schedule> schedules = snapshot.data!;
                  if (schedules.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 16),
                          Text('Jadwal belum tersedia.',
                            style: GoogleFonts.poppins(fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        return DaySchedule(schedule);
                      },
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DaySchedule extends StatelessWidget {
  final Schedule schedule;

  DaySchedule(this.schedule);

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
                  child: const Icon(
                    FontAwesomeIcons.calendarWeek,
                    color: Color(0xFF305E8B),
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${schedule.day}",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text("${schedule.startTime} - ${schedule.endTime}",
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
