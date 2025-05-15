import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/location_controller.dart';
import '../models/location_track.dart';

class LocationTrackingScreen extends StatelessWidget {
  final int guardId;
  final int shiftId;
  final LocationController locationController = Get.put(LocationController());

  LocationTrackingScreen({
    Key? key, 
    required this.guardId,
    required this.shiftId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => locationController.refreshTrackingHistory(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final currentPos = locationController.currentPosition.value;
              final history = locationController.trackingHistory;
              
              return FlutterMap(
                options: MapOptions(
                  center: currentPos,
                  zoom: 15,
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
                        builder: (context) => const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 40,
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
                    onPressed: () => locationController.startTracking(guardId, shiftId),
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