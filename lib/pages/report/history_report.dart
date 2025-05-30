import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrol_track_mobile/components/header.dart';
import 'package:patrol_track_mobile/components/history_card.dart';
import 'package:patrol_track_mobile/core/controllers/report_controller.dart';
import 'package:patrol_track_mobile/core/models/report.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';
import 'package:patrol_track_mobile/components/video_thumbnail_widget.dart';
import 'package:patrol_track_mobile/components/video_player_widget.dart';
import 'package:patrol_track_mobile/pages/report/report_detail.dart';

class HistoryReport extends StatefulWidget {
  @override
  _HistoryReportState createState() => _HistoryReportState();
}

class _HistoryReportState extends State<HistoryReport> {
  late Future<List<Report>> _futureReport;
  final String baseFileUrl = "https://jejakpatroli.my.id/";

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

  bool isVideo(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return extension == 'mp4' || extension == 'mov';
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
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportDetailPage(report: report),
                            ),
                          );
                        },
                        child: Card(
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
                                      Container(
                                        width: 80.0 * report.attachments.length,
                                        height: 60,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: report.attachments.length,
                                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                                          itemBuilder: (context, i) {
                                            final file = report.attachments[i];
                                            final fileUrl = file.startsWith('http') ? file : baseFileUrl + file.replaceAll('\\', '/');
                                            if (isVideo(file)) {
                                              return GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => Dialog(
                                                      child: VideoPlayerWidget(videoUrl: fileUrl),
                                                    ),
                                                  );
                                                },
                                                child: VideoThumbnailWidget(
                                                  videoUrl: fileUrl,
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) => Dialog(
                                                        child: VideoPlayerWidget(videoUrl: fileUrl),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            } else {
                                              return GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => Dialog(
                                                      child: Image.network(fileUrl, fit: BoxFit.contain),
                                                    ),
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    fileUrl,
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => Container(
                                                      width: 60,
                                                      height: 60,
                                                      color: Colors.grey[300],
                                                      child: const Icon(Icons.broken_image, size: 24),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
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