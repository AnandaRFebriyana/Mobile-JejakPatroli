import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrol_track_mobile/components/header.dart';
import 'package:patrol_track_mobile/core/controllers/schedule_controller.dart';
import 'package:patrol_track_mobile/core/models/schedule.dart';
import 'package:intl/intl.dart';

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
                    // Filter schedules to only show today or future schedules
                    DateTime today = DateTime.now();
                    List<Schedule> relevantSchedules = schedules.where((schedule) {
                      // If scheduleDate is null, always show it (assuming it's a recurring weekly schedule)
                      if (schedule.scheduleDate == null) {
                        return true;
                      }
                      // Otherwise, only show if the date is today or in the future
                      // Compare only dates, ignore time
                      return schedule.scheduleDate!.isAfter(today.subtract(Duration(days: 1)));
                    }).toList();

                    if (relevantSchedules.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 16),
                            Text('Tidak ada jadwal yang akan datang.',
                              style: GoogleFonts.poppins(fontSize: 15),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: relevantSchedules.length,
                        itemBuilder: (context, index) {
                          final schedule = relevantSchedules[index];
                          return DaySchedule(schedule);
                        },
                      );
                    }
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

  DaySchedule(this.schedule) {
    print('Building DaySchedule widget:');
    print('Day: ${schedule.day}');
    print('Schedule Date: ${schedule.scheduleDate}');
    print('Start Time: ${schedule.startTime}');
    print('End Time: ${schedule.endTime}');
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${schedule.day}",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (schedule.scheduleDate != null) ...[
                        Text(
                          DateFormat('dd MMMM yyyy', 'id_ID').format(schedule.scheduleDate!),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                      Text("${schedule.startTime} - ${schedule.endTime}",
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ],
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
