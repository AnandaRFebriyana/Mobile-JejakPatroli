import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:patrol_track_mobile/core/utils/Constant.dart';
import 'package:patrol_track_mobile/models/location_track.dart';

class LocationService {
  Future<String?> _getToken() async {
    return await Constant.getToken();
  }

  Future<List<LocationTrack>> getAllLocations() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak tersedia. Silakan login kembali.');
      }

      // Use the correct API endpoint from the Laravel controller
      final url = Uri.parse('${Constant.BASE_URL}/api/locations');
      print('Fetching all locations from: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': token,
          'Accept': 'application/json',
        },
      );
      
      print('Get all locations response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        
        // Check for the Laravel controller's specific response structure
        if (decodedData is Map && 
            decodedData.containsKey('status') && 
            decodedData['status'] == 'success' &&
            decodedData.containsKey('data')) {
          
          // Extract location data from the correct response structure  
          List<dynamic> locationList = decodedData['data'] as List<dynamic>;
          
          // Process each item and handle errors gracefully
          List<LocationTrack> results = [];
          for (var item in locationList) {
            try {
              if (item is Map<String, dynamic>) {
                results.add(LocationTrack.fromJson(item));
              } else {
                print('Skipping non-map item in locations: $item');
              }
            } catch (e) {
              print('Error parsing location item: $e');
            }
          }
          
          return results;
        } else {
          print('Unexpected data structure received from API: $decodedData');
          return [];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        print('Error getting locations: ${response.body}');
        throw Exception('Gagal mengambil lokasi: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getAllLocations: $e');
      return [];
    }
  }

  Future<LocationTrack> saveLocation(LocationTrack location) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        print('ERROR: Token is null or empty');
        throw Exception('Token tidak tersedia. Silakan login kembali.');
      }

      // Note: Your Constant.BASE_URL already includes /api, so don't add it again
      final url = Uri.parse('${Constant.BASE_URL}/locations');
      
      print('\n==== SENDING LOCATION DATA ====');
      print('URL: $url');
      
      // Create a simple payload that matches exactly what your Laravel controller expects
      final Map<String, dynamic> payload = {
        'shift_id': location.shiftId,
        'latitude': location.latitude,
        'longitude': location.longitude
      };
      print('Payload: $payload');
      
      // Try different authentication header formats
      String authHeader = token;
      if (!token.startsWith('Bearer ')) {
        authHeader = 'Bearer $token';
      }
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': authHeader,
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Location saved successfully!');
        return location; // Just return the original location, we don't need the server response
      } else {
        print('❌ Failed to save location: ${response.statusCode}');
        print('Response: ${response.body}');
        return location; // Return original to avoid crashes
      }
    } catch (e) {
      print('❌ Exception saving location: $e');
      return location; // Return original to avoid crashes
    }
  }

  Future<LocationTrack?> getLocationDetails(int locationId) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak tersedia. Silakan login kembali.');
      }

      // Use the correct API endpoint from the Laravel controller
      final url = Uri.parse('${Constant.BASE_URL}/api/locations/$locationId');
      print('Fetching location details from: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': token,
          'Accept': 'application/json',
        },
      );
      
      print('Get location details response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final decodedData = jsonDecode(response.body);
          
          // Check for the Laravel controller's specific response structure
          if (decodedData is Map && 
              decodedData.containsKey('status') && 
              decodedData['status'] == 'success' &&
              decodedData.containsKey('data')) {
            
            // Extract location data from the correct response structure
            Map<String, dynamic> locationData = decodedData['data'];
            return LocationTrack.fromJson(locationData);
          } else {
            print('Unexpected data structure received from API: $decodedData');
            return null;
          }
        } catch (e) {
          print('Error parsing location details response: $e');
          return null;
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else if (response.statusCode == 404) {
        print('Location not found: $locationId');
        return null;
      } else {
        print('Error getting location details: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getLocationDetails: $e');
      return null;
    }
  }

  Future<List<LocationTrack>> getTrackingHistory() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak tersedia. Silakan login kembali.');
      }

      // Use the correct API endpoint as defined in the Laravel controller
      final url = Uri.parse('${Constant.BASE_URL}/api/tracking-history');
      print('Fetching tracking history from: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': token,
          'Accept': 'application/json',
        },
      );
      
      print('Get tracking history response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        
        // Check for the Laravel controller's specific response structure
        if (decodedData is Map && 
            decodedData.containsKey('status') && 
            decodedData['status'] == 'success' &&
            decodedData.containsKey('data')) {
          
          // Extract the tracking logs array
          List<dynamic> locationList = decodedData['data'] as List<dynamic>;
          
          // Process each item and handle errors gracefully
          List<LocationTrack> results = [];
          for (var item in locationList) {
            try {
              if (item is Map<String, dynamic>) {
                results.add(LocationTrack.fromJson(item));
              } else {
                print('Skipping non-map item in tracking history: $item');
              }
            } catch (e) {
              print('Error parsing tracking history item: $e');
            }
          }
          
          return results;
        } else {
          print('Unexpected data structure received from API: $decodedData');
          return [];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesi telah berakhir. Silakan login kembali.');
      } else {
        print('Error getting tracking history: ${response.body}');
        throw Exception('Gagal mendapatkan riwayat tracking: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getTrackingHistory: $e');
      return [];
    }
  }

  // Test method to check API connectivity
  Future<bool> testApiConnection() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        print('⚠️ TEST CONNECTION: Token is null or empty!');
        return false;
      }

      print('🔍 TESTING API CONNECTION');
      print('  Base URL: ${Constant.BASE_URL}');
      
      // Try both with and without /api prefix
      final urls = [
        '${Constant.BASE_URL}/api/locations',
        '${Constant.BASE_URL}/locations',
      ];
      
      // Try different auth header formats
      final headers = [
        {'Authorization': token, 'Accept': 'application/json'},
        {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
        {'Authorization': 'Token $token', 'Accept': 'application/json'},
      ];
      
      for (var url in urls) {
        print('\n  Testing URL: $url');
        
        for (var header in headers) {
          print('  Testing with headers: $header');
          
          try {
            final response = await http.get(
              Uri.parse(url),
              headers: header,
            );
            
            print('  Response status: ${response.statusCode}');
            print('  Response body: ${response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body}');
            
            if (response.statusCode == 200 || response.statusCode == 201) {
              print('  ✅ Connection successful with this configuration!');
              return true;
            } else {
              print('  ❌ Failed with status ${response.statusCode}');
            }
          } catch (e) {
            print('  ❌ Error during test: $e');
          }
        }
      }
      
      print('❌ All connection tests failed');
      return false;
    } catch (e) {
      print('❌ Exception in testApiConnection: $e');
      return false;
    }
  }

  // For debugging - attempt to create a test location with minimal data
  Future<bool> createTestLocation() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        print('⚠️ TEST LOCATION: Token is null or empty!');
        return false;
      }

      print('🔍 ATTEMPTING TO CREATE TEST LOCATION');
      
      // Create a minimal payload with just required fields
      final Map<String, dynamic> payload = {
        'shift_id': 1,                   // Using a default ID as a test
        'latitude': 0.0,                 // Using 0,0 as test coordinates
        'longitude': 0.0
      };
      
      // Test different URL patterns
      final urls = [
        '${Constant.BASE_URL}/api/locations',
        '${Constant.BASE_URL}/locations',
        '${Constant.BASE_URL}/api/tracking-history'
      ];
      
      // Try with different authorization headers
      final authHeaders = [
        token,
        'Bearer $token',
        'Token $token'
      ];
      
      for (var url in urls) {
        print('\n  Testing POST to URL: $url');
        
        for (var authHeader in authHeaders) {
          print('  Testing with auth: ${authHeader.length > 15 ? authHeader.substring(0, 15) : authHeader}...');
          
          try {
            final response = await http.post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': authHeader,
                'Accept': 'application/json',
              },
              body: jsonEncode(payload),
            );
            
            print('  Response status: ${response.statusCode}');
            print('  Response body: ${response.body}');
            
            if (response.statusCode == 200 || response.statusCode == 201) {
              print('  ✅ Test location created successfully!');
              return true;
            } else {
              print('  ❌ Failed to create test location with status ${response.statusCode}');
            }
          } catch (e) {
            print('  ❌ Error creating test location: $e');
          }
        }
      }
      
      print('❌ All test location creation attempts failed');
      return false;
    } catch (e) {
      print('❌ Exception in createTestLocation: $e');
      return false;
    }
  }
} 