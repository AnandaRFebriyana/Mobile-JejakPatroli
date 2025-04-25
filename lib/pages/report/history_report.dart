import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrol_track_mobile/components/header.dart';
import 'package:patrol_track_mobile/components/history_card.dart';
import 'package:patrol_track_mobile/core/controllers/report_controller.dart';
import 'package:patrol_track_mobile/core/models/report.dart';
import 'package:intl/intl.dart';

class HistoryReport extends StatefulWidget {
  @override
  _HistoryReportState createState() => _HistoryReportState();
}

class _HistoryReportState extends State<HistoryReport> {
  late Future<List<Report>> _futureReport;

  @override
  void initState() {
    super.initState();
    _futureReport = ReportController.getReportHistory(context);
  }

  String formatTime(DateTime dateTime) {
    return DateFormat.Hm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(title: "Histori Laporan"),
          Expanded(
            child: FutureBuilder<List<Report>>(
              future: _futureReport,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Laporan belum tersedia.',
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                      ],
                    ),
                  );
                } else {
                  List<Report> reports = snapshot.data!;
                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return MyCard(
                        icon: IconType.Patrol,
                        title: "Patroli ${DateFormat('dd/MM/yyyy').format(report.createdAt)}",
                        subtitle: report.locationName,
                        time: formatTime(report.createdAt),
                        status: report.status,
                      );
                    },
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