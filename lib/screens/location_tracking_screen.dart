import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/location_controller.dart';
import '../models/location_track.dart';

class LocationTrackingScreen extends StatefulWidget {
  final int guardId;
  final int shiftId;

  const LocationTrackingScreen({
    Key? key, 
    required this.guardId,
    required this.shiftId,
  }) : super(key: key);

  @override
  State<LocationTrackingScreen> createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  late final LocationController locationController;
  final MapController mapController = MapController();
  bool isInitialPositionSet = false;

  @override
  void initState() {
    super.initState();
    print('Initializing LocationTrackingScreen');
    locationController = Get.put(LocationController());
    _initializeCurrentLocation();
  }

  Future<void> _initializeCurrentLocation() async {
    try {
      // Wait for position to be available
      await Future.delayed(Duration(seconds: 2));
      if (locationController.currentPosition.value.latitude != 0 && 
          locationController.currentPosition.value.longitude != 0) {
        _centerMap();
      } else {
        // Try to get position directly
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          print('Location services are disabled');
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            print('Location permissions are denied');
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          print('Location permissions are permanently denied');
          return;
        }

        Position position = await Geolocator.getCurrentPosition();
        print('Direct position: ${position.latitude}, ${position.longitude}');
        locationController.currentPosition.value = LatLng(position.latitude, position.longitude);
        _centerMap();
      }
    } catch (e) {
      print('Error initializing current location: $e');
    }
  }

  void _centerMap() {
    if (!isInitialPositionSet && mounted) {
      // Only center the map once when position is first available
      print('Centering map to: ${locationController.currentPosition.value}');
      mapController.move(
        locationController.currentPosition.value, 
        15
      );
      isInitialPositionSet = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              mapController.move(
                locationController.currentPosition.value, 
                mapController.zoom
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              locationController.refreshTrackingHistory();
              _initializeCurrentLocation();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final currentPos = locationController.currentPosition.value;
              final history = locationController.trackingHistory;
              
              // If we have a real position, center the map
              if (currentPos.latitude != 0 && currentPos.longitude != 0 && !isInitialPositionSet) {
                // Schedule centering after the build is complete
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _centerMap();
                });
              }
              
              print('Building map with current position: $currentPos');
              
              return FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center: currentPos,
                  zoom: 15,
                  onMapReady: () {
                    print('Map is ready');
                    _centerMap();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      // Current location marker
                      Marker(
                        point: currentPos,
                        width: 80,
                        height: 80,
                        builder: (context) => Container(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.person_pin_circle,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              Text(
                                'You are here',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  backgroundColor: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // History markers
                      ...history.map((location) => Marker(
                        point: LatLng(location.latitude, location.longitude),
                        width: 60,
                        height: 60,
                        builder: (context) => Tooltip(
                          message: 'Recorded at: ${location.createdAt}',
                          child: const Icon(
                            Icons.location_history,
                            color: Colors.orange,
                            size: 30,
                          ),
                        ),
                      )).toList(),
                    ],
                  ),
                ],
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() => locationController.isTracking.value
                ? ElevatedButton(
                    onPressed: () => locationController.stopTracking(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Stop Tracking'),
                  )
                : ElevatedButton(
                    onPressed: () => locationController.startTracking(widget.guardId, widget.shiftId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Start Tracking'),
                  )),
          ),
        ],
      ),
    );
  }
} 