import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapSatpam extends StatelessWidget {
  const MapSatpam({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Satpam'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: const LatLng(-7.3088, 112.7311),
              zoom: 30.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(-7.3088, 112.7311),
                    builder: (context) => GestureDetector(
                      onTap: () {
                        // Tambahkan aksi saat marker diklik
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Marker di lokasi Satpam')),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 4,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                // Tambahkan aksi untuk tombol ini, misalnya memperbesar peta
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.zoom_in),
            ),
          ),
        ],
      ),
    );
  }
}