import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:patrol_track_mobile/core/models/report.dart';
import 'package:patrol_track_mobile/core/utils/Constant.dart';

class ReportService {
  static Future<bool> todayReported(String token) async {
    final url = Uri.parse('${Constant.BASE_URL}/today-report');
    print('ReportService: Checking today report at URL: $url');
    
    final response = await http.get(
      url,
      headers: {'Authorization': token},
    );
    print('ReportService: Today report response status: ${response.statusCode}');
    print('ReportService: Today report response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['reported_today'];
    } else {
      throw Exception(
          'Failed to load patrol report. Status code: ${response.statusCode}');
    }
  }

  static Future<List<Report>> getAllReports(String token) async {
    final url = Uri.parse('${Constant.BASE_URL}/history-report');
    print('ReportService: Getting all reports from URL: $url');
    print('ReportService: Using token: ${token.substring(0, 10)}...');
    
    final response = await http.get(
      url,
      headers: {'Authorization': token},
    );
    print('ReportService: History report response status: ${response.statusCode}');
    print('ReportService: History report response body: ${response.body}');

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print('ReportService: Decoded response: $result');
      
      if (result['data'] == null) {
        print('ReportService: No data field in response');
        return [];
      }
      
      List<Report> reports = List<Report>.from(
        result['data'].map(
          (reports) => Report.fromJson(reports),
        ),
      );
      print('ReportService: Successfully parsed ${reports.length} reports');
      return reports;
    } else {
      print('ReportService: Failed to load reports. Status code: ${response.statusCode}');
      throw Exception('Failed to load reports');
    }
  }

  static Future<void> postReport(Report report) async {
    try {
      String? token = await Constant.getToken();
      if (token == null) {
        throw 'Token tidak tersedia. Silakan login kembali.';
      }

      final url = Uri.parse('${Constant.BASE_URL}/report/store');
      print('ReportService: Posting report to URL: $url');
      
      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = token;
      request.headers['Accept'] = 'application/json';

      request.fields['status'] = report.status;
      request.fields['description'] = report.description;
      
      print('ReportService: Report fields: ${request.fields}');
      
      for (String attachmentPath in report.attachments) {
        final file = File(attachmentPath);
        if (!await file.exists()) {
          throw 'File tidak ditemukan: $attachmentPath';
        }
        request.files.add(
          await http.MultipartFile.fromPath('attachment[]', attachmentPath),
        );
      }

      print('ReportService: Sending request...');
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      
      print('ReportService: Response status: ${response.statusCode}');
      print('ReportService: Response body: ${responseBody.body}');

      if (response.statusCode == 201) {
        print('ReportService: Report created successfully');
      } else {
        String errorMessage = responseBody.body;
        print('ReportService: Error response: $errorMessage');
        throw 'Gagal membuat laporan: $errorMessage';
      }
    } catch (e) {
      print('ReportService: Error in postReport: $e');
      throw e.toString();
    }
  }
}