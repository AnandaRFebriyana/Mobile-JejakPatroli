import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../models/location_track.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';
import 'package:http/http.dart' as http;

class LocationController extends GetxController {
  final LocationService _locationService = LocationService();
  final RxBool isTracking = false.obs;
  final Rx<LatLng> currentPosition = LatLng(0, 0).obs;
  final RxList<LocationTrack> trackingHistory = <LocationTrack>[].obs;
  Timer? _locationTimer;
  
  @override
  void onInit() {
    super.onInit();
    print('Location Controller initialized');
    _initializeLocation();
  }

  @override
  void onClose() {
    _locationTimer?.cancel();
    print('Location Controller closed');
    super.onClose();
  }
  
  Future<void> _initializeLocation() async {
    try {
      await _checkLocationPermission();
      await _getCurrentLocation();
      await _loadTrackingHistory();
    } catch (e) {
      print('Error initializing location: $e');
      Get.snackbar(
        'Error',
        'Failed to initialize location: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      print('Current position: ${position.latitude}, ${position.longitude}');
      currentPosition.value = LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      Get.snackbar(
        'Error',
        'Failed to get current location: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadTrackingHistory() async {
    try {
      print('Loading tracking history');
      List<LocationTrack> history = await _locationService.getTrackingHistory();
      print('Loaded ${history.length} tracking history items');
      trackingHistory.value = history;
    } catch (e) {
      print('Error loading tracking history: $e');
      Get.snackbar(
        'Error',
        'Failed to load tracking history: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        Get.snackbar(
          'Error',
          'Location services are disabled. Please enable location services.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('Requesting location permission');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied');
          Get.snackbar(
            'Error',
            'Location permissions are denied. Please enable location permissions.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        Get.snackbar(
          'Error',
          'Location permissions are permanently denied. Please enable location permissions in settings.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return Future.error('Location permissions are permanently denied');
      }
      
      print('Location permission granted');
    } catch (e) {
      print('Error checking location permission: $e');
      Get.snackbar(
        'Error',
        'Failed to check location permission: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> startTracking(int attendanceId, int guardId) async {
    try {
      print('\n==== STARTING LOCATION TRACKING ====');
      print('Attendance ID: $attendanceId, Guard ID: $guardId');
      
      await _checkLocationPermission();
      isTracking.value = true;

      // Get and save current location
      final position = await Geolocator.getCurrentPosition();
      print('Initial position: ${position.latitude}, ${position.longitude}');
      currentPosition.value = LatLng(position.latitude, position.longitude);
      
      // Save location using direct API
      await _directSaveLocation(attendanceId, guardId, position);

      // Set up continuous tracking with 30 second interval
      _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
        if (isTracking.value) {
          try {
            print('\n[${DateTime.now()}] Sending location update...');
            final newPosition = await Geolocator.getCurrentPosition();
            print('New position: ${newPosition.latitude}, ${newPosition.longitude}');
            currentPosition.value = LatLng(newPosition.latitude, newPosition.longitude);
            
            // Save location with direct API
            await _directSaveLocation(attendanceId, guardId, newPosition);
            print('Location update sent successfully');
          } catch (e) {
            print('Error in location update: $e');
            // Try to restart tracking if there's an error
            if (isTracking.value) {
              print('Attempting to restart tracking...');
              startTracking(attendanceId, guardId);
            }
          }
        } else {
          print('Tracking stopped, cancelling timer');
          timer.cancel();
        }
      });
      
      print('Location tracking started with 30 second interval!\n');
      Get.snackbar(
        'Tracking Aktif',
        'Lokasi Anda sedang dilacak setiap 30 detik',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Error starting tracking: $e');
      isTracking.value = false;
      Get.snackbar(
        'Error',
        'Gagal memulai pelacakan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // Direct save location to API
  Future<void> _directSaveLocation(int attendanceId, int guardId, Position position) async {
    try {
      final token = await Constant.getToken();
      if (token == null || token.isEmpty) {
        print('ERROR: Token not available');
        return;
      }
      
      // Prepare request to match Laravel controller
      final url = Uri.parse('${Constant.BASE_URL}/update-location');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': token,  // Just use the token directly
      };
      final body = jsonEncode({
        'attendance_id': attendanceId,
        'latitude': position.latitude,
        'longitude': position.longitude
      });
      
      print('Sending location to: $url');
      print('Headers: $headers');  // Debug print headers
      final response = await http.post(url, headers: headers, body: body);
      
      print('Response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Location saved successfully');
      } else {
        print('❌ Failed to save location: ${response.statusCode}');
        print('Response body: ${response.body}');  // Print response body for debugging
      }
    } catch (e) {
      print('❌ Error saving location: $e');
    }
  }

  Future<void> stopTracking() async {
    try {
      print('Stopping location tracking');
      isTracking.value = false;
      _locationTimer?.cancel();
      await _loadTrackingHistory(); // Reload history after stopping
      
      print('Location tracking stopped');
      Get.snackbar(
        'Tracking Stopped',
        'Your location tracking has been stopped',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.7),
        colorText: Get.theme.colorScheme.onError,
      );
    } catch (e) {
      print('Error stopping tracking: $e');
      Get.snackbar(
        'Error',
        'Failed to stop tracking: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> testConnection() async {
    try {
      print('Testing API connection...');
      bool apiOk = false;
      
      // Test API connection
      try {
        apiOk = await _locationService.testApiConnection();
        print('API connection test: ${apiOk ? "SUCCESS" : "FAILED"}');
      } catch (e) {
        print('API test error: $e');
      }
      
      // Show results to user
      Get.snackbar(
        'Connection Test Results',
        'API: ${apiOk ? "✅" : "❌"}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      print('Error in testConnection: $e');
    }
  }

  Future<void> refreshTrackingHistory() async {
    try {
      print('Manually refreshing tracking history');
      await _loadTrackingHistory();
      print('Tracking history refreshed');
      Get.snackbar(
        'Refreshed',
        'Tracking history has been refreshed',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error refreshing tracking history: $e');
    }
  }
} 