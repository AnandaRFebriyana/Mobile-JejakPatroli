import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:patrol_track_mobile/core/utils/Constant.dart';
import 'package:patrol_track_mobile/models/location_track.dart';

class FirebaseLocationService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  }
  
  // Save location to Firebase
  Future<bool> saveLocation(int guardId, int shiftId, double latitude, double longitude) async {
    try {
      // Get current timestamp
      final timestamp = DateTime.now().toIso8601String();
      
      // Create a reference to the user's locations
      final locationRef = _database.child('locations').push();
      
      // Save the location data
      await locationRef.set({
        'guard_id': guardId,
        'shift_id': shiftId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
      });
      
      print('✅ Location saved to Firebase successfully!');
      return true;
    } catch (e) {
      print('❌ Error saving location to Firebase: $e');
      return false;
    }
  }
  
  // Get location history for a specific guard
  Future<List<LocationTrack>> getLocationHistory(int guardId) async {
    try {
      final snapshot = await _database
          .child('locations')
          .orderByChild('guard_id')
          .equalTo(guardId)
          .get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<LocationTrack> locations = [];
        
        data.forEach((key, value) {
          try {
            final locationData = Map<String, dynamic>.from(value as Map);
            locations.add(LocationTrack(
              id: key,
              guardId: locationData['guard_id'],
              shiftId: locationData['shift_id'],
              latitude: locationData['latitude'],
              longitude: locationData['longitude'],
              createdAt: locationData['timestamp'],
              updatedAt: locationData['timestamp'],
            ));
          } catch (e) {
            print('Error parsing location data: $e');
          }
        });
        
        // Sort by timestamp (newest first)
        locations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return locations;
      }
      
      return [];
    } catch (e) {
      print('❌ Error getting location history from Firebase: $e');
      return [];
    }
  }
  
  // Get all locations for a specific shift
  Future<List<LocationTrack>> getShiftLocations(int shiftId) async {
    try {
      final snapshot = await _database
          .child('locations')
          .orderByChild('shift_id')
          .equalTo(shiftId)
          .get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<LocationTrack> locations = [];
        
        data.forEach((key, value) {
          try {
            final locationData = Map<String, dynamic>.from(value as Map);
            locations.add(LocationTrack(
              id: key,
              guardId: locationData['guard_id'],
              shiftId: locationData['shift_id'],
              latitude: locationData['latitude'],
              longitude: locationData['longitude'],
              createdAt: locationData['timestamp'],
              updatedAt: locationData['timestamp'],
            ));
          } catch (e) {
            print('Error parsing location data: $e');
          }
        });
        
        // Sort by timestamp (oldest first for tracking routes)
        locations.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return locations;
      }
      
      return [];
    } catch (e) {
      print('❌ Error getting shift locations from Firebase: $e');
      return [];
    }
  }
  
  // Test Firebase connection
  Future<bool> testFirebaseConnection() async {
    try {
      final connectionRef = _database.child('.info/connected');
      final snapshot = await connectionRef.get();
      
      return snapshot.exists && snapshot.value == true;
    } catch (e) {
      print('❌ Error testing Firebase connection: $e');
      return false;
    }
  }
} 