import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:patrol_track_mobile/core/models/report.dart';
import 'package:patrol_track_mobile/core/utils/Constant.dart';

class ReportService {
  static Future<bool> todayReported(String token) async {
    final url = Uri.parse('${Constant.BASE_URL}/today-report');
    final response = await http.get(
      url,
      headers: {'Authorization': '$token'},
    );

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
    final response = await http.get(
      url,
      headers: {'Authorization': '$token'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      // print(result);
      List<Report> reports = List<Report>.from(
        result['data'].map(
          (reports) => Report.fromJson(reports),
        ),
      );
      return reports;
    } else {
      throw Exception('Failed to load reports');
    }
  }

  static Future<void> postReport(Report report) async {
    try {
      String? token = await Constant.getToken();
      final url = Uri.parse('${Constant.BASE_URL}/report/store');
      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = '$token';
      request.headers['Accept'] = 'application/json';

      request.fields['location_id'] = report.locationId.toString();
      request.fields['status'] = report.status;
      request.fields['description'] = report.description;
      
      for (File attachment in report.attachments) {
        request.files.add(
          await http.MultipartFile.fromPath('attachment[]', attachment.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        print('Successfully create report.');
      } else {
        // throw 'Status Code: ${response.statusCode}';
        String errorMessage = await response.stream.bytesToString();
        throw 'Failed to create report: $errorMessage';
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}