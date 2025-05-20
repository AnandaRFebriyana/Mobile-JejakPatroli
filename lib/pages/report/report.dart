import 'dart:io';
import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:patrol_track_mobile/components/snackbar.dart';
import 'package:patrol_track_mobile/core/controllers/report_controller.dart';
import 'package:patrol_track_mobile/core/models/report.dart';
import 'package:patrol_track_mobile/components/button.dart';
import 'package:patrol_track_mobile/components/header.dart';


class ReportPage extends StatefulWidget {
  final String scanResult;

  ReportPage({required this.scanResult}) {
    // Validasi scanResult saat widget dibuat
    try {
      int.parse(scanResult.trim());
    } catch (e) {
      print('Warning: Invalid scan result format: $scanResult');
    }
  }

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late TextEditingController _result;
  String? _status;
  late String _currentTime;
  final TextEditingController _desc = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<MediaItem> _mediaItems = [];
  bool _notesNotSelected = false;
  bool _imageReportNotSelected = false;
  bool _statusNotSlected = false;
  File? _selectedMedia;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    // Bersihkan input sebelum digunakan
    _result = TextEditingController(text: widget.scanResult.trim());
    _updateTime();
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    });
    Future.delayed(Duration(seconds: 1), _updateTime);
  }

  Future<void> _saveReport() async {
    try {
      // Debug print untuk melihat nilai setiap field
      print('=== Debug Info Form ===');
      print('Status: $_status');
      print('Deskripsi: ${_desc.text}');
      print('Media Items: ${_mediaItems.length} items');
      
      // Reset status error
      setState(() {
        _statusNotSlected = false;
        _notesNotSelected = false;
        _imageReportNotSelected = false;
      });

      // Validasi form
      String errorMessage = '';
      
      if (_status == null || _status!.isEmpty) {
        setState(() => _statusNotSlected = true);
        errorMessage += 'Status Lokasi, ';
      }
      
      if (_desc.text.trim().isEmpty) {
        setState(() => _notesNotSelected = true);
        errorMessage += 'Catatan Patroli, ';
      }
      
      if (_mediaItems.isEmpty) {
        setState(() => _imageReportNotSelected = true);
        errorMessage += 'Foto/Video';
      }

      // Jika ada error, tampilkan pesan
      if (errorMessage.isNotEmpty) {
        errorMessage = 'Mohon lengkapi: ' + errorMessage.replaceAll(RegExp(r', $'), '');
        print('Validation Error: $errorMessage');
        MySnackbar.failure(context, errorMessage);
        return;
      }

      // Kirim laporan tanpa location ID
      print('Mengirim laporan...');
      final report = Report(
        id: 0, // ID akan di-generate oleh server
        guardId: 0, // Guard ID akan di-set oleh server
        status: _status!,
        description: _desc.text.trim(),
        attachments: _mediaItems.map((item) => item.file.path).toList(),
        createdAt: DateTime.now(),
      );

      await ReportController.createReport(context, report);
      print('Laporan berhasil dikirim!');

    } catch (e) {
      print('Error dalam proses pengiriman: $e');
      MySnackbar.failure(context, 'Terjadi kesalahan saat mengirim laporan');
    }
  }

  Future<File> compressImage(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));
    if (image == null) {
      throw Exception('Failed to decode image.');
    }
    int maxWidth = 800;
    if (image.width <= maxWidth) {
      return imageFile;
    }
    img.Image resizedImage = img.copyResize(image, width: maxWidth);
    Directory tempDir = await Directory.systemTemp;
    String tempPath = tempDir.path;
    File compressedFile =
        File('$tempPath/compressed_${imageFile.path.split('/').last}');
    await compressedFile.writeAsBytes(img.encodeJpg(resizedImage, quality: 50));

    return compressedFile;
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );
      
      if (photo != null) {
        File photoFile = File(photo.path);
        
        // Pastikan file ada dan bisa diakses
        if (await photoFile.exists()) {
          setState(() {
            _mediaItems.add(MediaItem(file: photoFile, isVideo: false));
            _imageReportNotSelected = false;
          });
          print('Foto berhasil ditambahkan: ${photoFile.path}');
        } else {
          print('Error: File foto tidak ditemukan');
          MySnackbar.failure(context, 'Gagal menyimpan foto');
        }
      }
    } catch (e) {
      print('Error saat mengambil foto: $e');
      MySnackbar.failure(context, 'Gagal mengambil foto');
    }
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10),
      );
      
      if (video != null) {
        File videoFile = File(video.path);
        
        // Pastikan file ada dan bisa diakses
        if (await videoFile.exists()) {
          setState(() {
            _mediaItems.add(MediaItem(file: videoFile, isVideo: true));
            _imageReportNotSelected = false;
          });
          print('Video berhasil ditambahkan: ${videoFile.path}');
        } else {
          print('Error: File video tidak ditemukan');
          MySnackbar.failure(context, 'Gagal menyimpan video');
        }
      }
    } catch (e) {
      print('Error saat merekam video: $e');
      MySnackbar.failure(context, 'Gagal merekam video');
    }
  }

  void _removeMedia(int index) {
    if (index >= 0 && index < _mediaItems.length) {
      setState(() {
        _mediaItems.removeAt(index);
        _imageReportNotSelected = _mediaItems.isEmpty;
      });
      print('Media dihapus, sisa ${_mediaItems.length} item');
    }
  }

  @override
  void dispose() {
    _result.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(title: "Report", backButton: true),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: StreamBuilder<DateTime>(
                        stream: Stream.periodic(
                            const Duration(seconds: 1), (_) => DateTime.now()),
                        builder: (context, snapshot) {
                          return Text(
                            DateFormat('dd-MM-yyyy HH:mm:ss')
                                .format(DateTime.now()),
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFF5F5C5C)),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                          child: Text(
                            widget.scanResult,
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "Status Lokasi",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF5F5C5C)),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                        child: DropdownButton<String>(
                          value: _status,
                          hint: Text('Pilih Status Lokasi'),
                          isExpanded: true,
                          items: <String>['Aman', 'Tidak Aman'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _status = newValue;
                              _statusNotSlected = false;
                            });
                          },
                          underline: Container(),
                        ),
                      ),
                    ),
                    if (_statusNotSlected)
                      Text(
                        'Please select a status',
                        style: TextStyle(color: Colors.red),
                      ),

                    SizedBox(height: 16.0),
                    Text(
                      "Catatan Patroli",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _desc,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        setState(() {
                          _notesNotSelected = false;
                        });
                      },
                    ),
                    if (_notesNotSelected)
                      Text(
                        'Please enter a reason',
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                    const SizedBox(height: 20),
                    Text(
                      "Unggah Bukti",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B71CA),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Text(
                                              'Pilih Media',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                          _takePhoto();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Icon(Icons.camera_alt, color: Colors.grey[700]),
                                              const SizedBox(width: 16),
                                              Text(
                                                'Ambil Foto',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Divider(height: 1),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                          _recordVideo();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Icon(Icons.videocam, color: Colors.grey[700]),
                                              const SizedBox(width: 16),
                                              Text(
                                                'Ambil Video',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.camera_alt, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Pilih File',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_mediaItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Column(
                        children: _mediaItems.asMap().entries.map((entry) {
                          int idx = entry.key;
                          MediaItem item = entry.value;
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item.isVideo ? Icons.videocam : Icons.image,
                                  color: Colors.grey[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.fileName,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeMedia(idx),
                                  icon: const Icon(Icons.close),
                                  color: Colors.grey[700],
                                  iconSize: 20,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 30),
                    MyButton(
                      text: "Kirim",
                      onPressed: _saveReport,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Class untuk menyimpan informasi media
class MediaItem {
  final File file;
  final bool isVideo;
  final String fileName;

  MediaItem({required this.file, required this.isVideo})
      : fileName = file.path.split('/').last;
}
