import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/report_model.dart';

class ReportService {
  static const String baseUrl = 'YOUR_API_BASE_URL'; // Ganti dengan URL API Anda

  Future<bool> submitReport(Report report, File? mediaFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/reports'),
      );

      // Tambahkan data report
      request.fields['status_lokasi'] = report.statusLokasi;
      request.fields['catatan_patroli'] = report.catatanPatroli;
      request.fields['timestamp'] = report.timestamp;
      request.fields['is_video'] = report.isVideo.toString();

      // Tambahkan file media jika ada
      if (mediaFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'media',
            mediaFile.path,
          ),
        );
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Report submitted successfully');
        return true;
      } else {
        print('Failed to submit report: ${response.statusCode}');
        print('Response: $responseData');
        return false;
      }
    } catch (e) {
      print('Error submitting report: $e');
      return false;
    }
  }
} 