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
    print('HistoryReport: Initializing...');
    _futureReport = ReportController.getReportHistory(context);
    _futureReport.then((reports) {
      print('HistoryReport: Received ${reports.length} reports');
      reports.forEach((report) {
        print('Report: ${report.id} - ${report.status} - ${report.createdAt}');
      });
    }).catchError((error) {
      print('HistoryReport: Error fetching reports: $error');
    });
  }

  String formatTime(DateTime dateTime) {
    return DateFormat.Hm().format(dateTime);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aman':
        return Colors.green;
      case 'tidak aman':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'aman':
        return 'Aman';
      case 'tidak aman':
        return 'Tidak Aman';
      default:
        return status;
    }
  }

  String getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'Gambar';
      case 'mp4':
      case 'mov':
        return 'Video';
      default:
        return 'File';
    }
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
                print('HistoryReport: Building with snapshot state: ${snapshot.connectionState}');
                print('HistoryReport: Has data: ${snapshot.hasData}');
                print('HistoryReport: Has error: ${snapshot.hasError}');
                if (snapshot.hasError) {
                  print('HistoryReport: Error details: ${snapshot.error}');
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memuat data...'),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Terjadi kesalahan: ${snapshot.error}',
                          style: GoogleFonts.poppins(fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  print('HistoryReport: No data available');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada laporan patroli',
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                      ],
                    ),
                  );
                } else {
                  List<Report> reports = snapshot.data!;
                  print('HistoryReport: Building list with ${reports.length} reports');
                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      print('HistoryReport: Building item $index: ${report.id}');
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Laporan #${report.id}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: getStatusColor(report.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      getStatusText(report.status),
                                      style: GoogleFonts.poppins(
                                        color: getStatusColor(report.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Deskripsi: ${report.description}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Waktu: ${DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (report.attachments.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          report.attachments.first.toLowerCase().endsWith('.mp4')
                                              ? Icons.videocam
                                              : Icons.image,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${report.attachments.length} ${getFileType(report.attachments.first)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
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