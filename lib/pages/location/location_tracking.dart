import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:patrol_track_mobile/controllers/location_controller.dart';
import 'package:patrol_track_mobile/core/utils/Constant.dart';

class LocationTrackingPage extends StatefulWidget {
  final int guardId;
  final int shiftId;

  const LocationTrackingPage({
    Key? key,
    required this.guardId,
    required this.shiftId,
  }) : super(key: key);

  @override
  _LocationTrackingPageState createState() => _LocationTrackingPageState();
}

class _LocationTrackingPageState extends State<LocationTrackingPage> {
  final LocationController locationController = Get.find<LocationController>();
  final mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Automatically start tracking when the page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTracking();
    });
  }

  @override
  void dispose() {
    // Stop tracking when the page is closed
    locationController.stopTracking();
    super.dispose();
  }

  void startTracking() {
    locationController.startTracking(widget.guardId, widget.shiftId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracking'),
        actions: [
          // Connection test button
          IconButton(
            icon: const Icon(Icons.network_check),
            onPressed: () {
              locationController.testConnection();
            },
            tooltip: 'Test Connection',
          ),
        ],
      ),
      body: Column(
        children: [
          // Information card
          Card(
            elevation: 4,
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracking System',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  ListTile(
                    title: Text(
                      'Using API Connection',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Location tracking via server API connection',
                    ),
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Map view
          Expanded(
            child: Obx(() {
              final position = locationController.currentPosition.value;
              return FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center: LatLng(position.latitude, position.longitude),
                  zoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.jejakpatroli.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(position.latitude, position.longitude),
                        builder: (ctx) => Container(
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40.0,
                          ),
                        ),
                      ),
                      // Add marker for target location if patrolling specific area
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(Constant.targetLatitude, Constant.targetLongitude),
                        builder: (ctx) => Container(
                          child: Icon(
                            Icons.flag,
                            color: Colors.blue,
                            size: 40.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Optional: Add polylines for patrol routes
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: locationController.trackingHistory
                            .map((loc) => LatLng(loc.latitude, loc.longitude))
                            .toList(),
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
          
          // Status panel
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Column(
              children: [
                Obx(() {
                  return Text(
                    'Tracking Status: ${locationController.isTracking.value ? "Active" : "Inactive"}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: locationController.isTracking.value
                          ? Colors.green
                          : Colors.red,
                    ),
                  );
                }),
                const SizedBox(height: 8.0),
                Obx(() {
                  final position = locationController.currentPosition.value;
                  return Text(
                    'Current Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
                    style: TextStyle(fontSize: 12.0),
                  );
                }),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                      onPressed: () {
                        locationController.startTracking(
                          widget.guardId,
                          widget.shiftId,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                      onPressed: () {
                        locationController.stopTracking();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      onPressed: () {
                        locationController.refreshTrackingHistory();
                        // Center map on current position
                        final position = locationController.currentPosition.value;
                        mapController.move(
                          LatLng(position.latitude, position.longitude),
                          15.0,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 