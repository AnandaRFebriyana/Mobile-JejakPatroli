import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:patrol_track_mobile/components/button.dart';
import 'package:patrol_track_mobile/components/header.dart';
import 'package:patrol_track_mobile/core/controllers/attendance_controller.dart';
import 'package:patrol_track_mobile/core/utils/constant.dart';

class Presensi extends StatefulWidget {
  @override
  _PresensiState createState() => _PresensiState();
}

class _PresensiState extends State<Presensi> {
  Position? _currentLocation;
  String _currentAddress = "";
  bool _isAtTargetLocation = false;
  File? _image;
  int? _id;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _image = args['image'] as File?;
    _id = args['id'] as int?;
    _initializeLocation();
  }

  Future<void> _saveAttendance() async {
    if (_id != null && _image != null) {
      await AttendanceController.saveCheckIn(
        context,
        id: _id!,
        checkIn: TimeOfDay.now(),
        longitude: _currentLocation!.longitude,
        latitude: _currentLocation!.latitude,
        locationAddress: _currentAddress,
        photo: _image,
      );
    } else {
      throw "Image or Id is not available.";
    }
  }

  Future<void> _initializeLocation() async {
    try {
      _currentLocation = await _getCurrentLocation();
      if (_currentLocation != null) {
        await _getAddressFromCoordinates();
        _checkIfAtTargetLocation();
      }
    } catch (e) {
      print("Error initializing location: $e");
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permissions are permanently denied");
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
      Placemark place = placemarks.first;
      setState(() {
        _currentAddress = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
      });
    } catch (e) {
      print("Error getting address: $e");
    }
  }

  void _checkIfAtTargetLocation() {
    double distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      Constant.targetLatitude,
      Constant.targetLongitude,
    );
    setState(() {
      _isAtTargetLocation = distance <= Constant.allowedDistance;
    });
    
    print(_isAtTargetLocation
        ? "You are within the allowed distance from the target location."
        : "You are outside the allowed distance from the target location.");
    
    // if (!_isAtTargetLocation) {
    //   QuickAlert.show(
    //     context: context,
    //     type: QuickAlertType.info,
    //     title: 'Info!',
    //     text: 'You are outside the allowed distance from the target location.',
    //     onConfirmBtnTap: () {
    //       Navigator.of(context).pop();
    //       Get.toNamed('/menu-nav');
    //     },
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(title: "Presensi", backButton: true),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      height: 250,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _image == null
                          ? const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 200,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                                height: 250,
                                width: 200,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      DateFormat('dd-MM-yyyy').format(DateTime.now()),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    StreamBuilder<DateTime>(
                      stream: Stream.periodic(
                          const Duration(seconds: 1), (_) => DateTime.now()),
                      builder: (context, snapshot) {
                        return Text(
                          DateFormat('HH:mm:ss').format(DateTime.now()),
                          style: GoogleFonts.poppins(fontSize: 15),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              _currentAddress.isNotEmpty
                                  ? _currentAddress
                                  : "Loading...",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                              ),
                              softWrap: true,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      text: "Simpan Presensi",
                      onPressed: () => _saveAttendance(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the Firebase tracking page
                        Get.toNamed('/firebase-tracking', arguments: {
                          'guard_id': _id ?? 1,
                          'shift_id': 1,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(width: 8),
                          Text('Start Firebase Tracking'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}