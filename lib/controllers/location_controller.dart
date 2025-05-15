import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../models/location_track.dart';

class LocationController extends GetxController {
  final LocationService _locationService = LocationService();
  final RxBool isTracking = false.obs;
  final Rx<LatLng> currentPosition = LatLng(0, 0).obs;
  final RxList<LocationTrack> trackingHistory = <LocationTrack>[].obs;
  Timer? _locationTimer;
  
  @override
  void onInit() {
    super.onInit();
    _checkLocationPermission();
    _loadTrackingHistory();
  }

  @override
  void onClose() {
    _locationTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadTrackingHistory() async {
    try {
      final history = await _locationService.getTrackingHistory();
      trackingHistory.value = history;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load tracking history: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }
  }

  Future<void> startTracking(int guardId, int shiftId) async {
    await _checkLocationPermission();
    isTracking.value = true;

    // Save initial location
    Position position = await Geolocator.getCurrentPosition();
    currentPosition.value = LatLng(position.latitude, position.longitude);
    await _saveLocation(guardId, shiftId, position);

    // Start periodic location updates
    _locationTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (isTracking.value) {
        position = await Geolocator.getCurrentPosition();
        currentPosition.value = LatLng(position.latitude, position.longitude);
        await _saveLocation(guardId, shiftId, position);
      }
    });
  }

  Future<void> stopTracking() async {
    isTracking.value = false;
    _locationTimer?.cancel();
    await _loadTrackingHistory(); // Reload history after stopping
  }

  Future<void> _saveLocation(int guardId, int shiftId, Position position) async {
    try {
      final now = DateTime.now().toIso8601String();
      final location = LocationTrack(
        latitude: position.latitude,
        longitude: position.longitude,
        guardId: guardId,
        shiftId: shiftId,
        createdAt: now,
        updatedAt: now,
      );
      await _locationService.saveLocation(location);
      await _loadTrackingHistory(); // Reload history after saving new location
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save location: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refreshTrackingHistory() async {
    await _loadTrackingHistory();
  }
} 