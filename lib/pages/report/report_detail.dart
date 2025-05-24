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

class ReportDetailPage extends StatelessWidget {
  final Report report;

  const ReportDetailPage({Key? key, required this.report}) : super(key: key);

  bool isImage(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png');
  }

  bool isVideo(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.mp4') || ext.endsWith('.mov');
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

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'aman':
        return Icons.check_circle;
      case 'tidak aman':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final attachments = report.attachments;
    final String baseFileUrl = "https://jejakpatroli.my.id/";
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text('Detail Laporan', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul & Status
                  Row(
                    children: [
                      Icon(getStatusIcon(report.status), color: getStatusColor(report.status), size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Laporan #${report.id}',
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: getStatusColor(report.status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(getStatusIcon(report.status), color: getStatusColor(report.status), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              report.status,
                              style: GoogleFonts.poppins(
                                color: getStatusColor(report.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Divider(),
                  const SizedBox(height: 10),
                  // Deskripsi
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.description, color: Colors.blueGrey, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          report.description,
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Waktu
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.blueGrey, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt),
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(),
                  const SizedBox(height: 10),
                  // Lampiran
                  Text(
                    'Lampiran:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (attachments.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.image_not_supported, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada lampiran',
                            style: GoogleFonts.poppins(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: attachments.map((file) {
                        final fileUrl = file.startsWith('http') ? file : baseFileUrl + file.replaceAll('\\', '/');
                        print('Lampiran URL: $fileUrl');
                        if (isImage(file)) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      fileUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        print('Error loading image: $error');
                                        print('Image URL: $fileUrl');
                                        print('Stack trace: $stackTrace');
                                        return Container(
                                          width: 200,
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.broken_image, size: 40),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Gagal memuat gambar',
                                                style: GoogleFonts.poppins(color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                fileUrl,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading thumbnail: $error');
                                  print('Thumbnail URL: $fileUrl');
                                  print('Stack trace: $stackTrace');
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[300],
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.broken_image, size: 24),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Gagal memuat',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        } else if (isVideo(file)) {
                          return VideoThumbnailWidget(
                            videoUrl: fileUrl,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => Dialog(
                                  child: VideoPlayerWidget(videoUrl: fileUrl),
                                ),
                              );
                            },
                          );
                        } else {
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.insert_drive_file, size: 40, color: Colors.grey),
                          );
                        }
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
