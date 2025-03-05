import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:patrol_track_mobile/core/models/permission.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';

class PermissionService {

  static Future<bool> postPermission(String token, Permission permission) async {
    try {
      final url = Uri.parse('${Constant.BASE_URL}/permission');
      final request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = '$token';
      request.headers['Accept'] = 'application/json';

      request.fields['permission_date'] = permission.permissionDate;
      request.fields['reason'] = permission.reason;

      if (permission.information != null) {
        request.files.add(
          await http.MultipartFile.fromPath('information', permission.information!.path),
        );
      }
      // if (permission.information != null) {
      //   final mimeTypeData = lookupMimeType(permission.information!.path,
      //       headerBytes: [0xFF, 0xD8])?.split('/');
      //   request.files.add(
      //     await http.MultipartFile.fromPath(
      //       'information', permission.information!.path,
      //       contentType: mimeTypeData != null ? MediaType(mimeTypeData[0], mimeTypeData[1]) : null,
      //     ),
      //   );
      // }
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

       if (response.statusCode == 201) {
        return true;
      } else {
        final errorResult = jsonDecode(responseData);
        throw '${errorResult['message'] ?? 'Unknown error occurred'}';
      }
    } catch (error) {
      throw 'Error occurred: $error';
    }
  }
}