import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fortis_apps/core/data/repositories/attendance_repository.dart';
import 'package:fortis_apps/core/data/repositories/auth_repository.dart';

import '../../../core/data/models/auth_model.dart';

class HomeController extends GetxController {
  final AttendanceRepository _attendanceRepository = AttendanceRepositoryImpl();
  final AuthRepository _authRepository = AuthRepositoryImpl();
  var location = "Detecting...".obs;
  var city = "Unknown".obs;
  var province = "Unknown".obs;
  var country = "Unknown".obs;
  var currentUser = Rxn<UserModel>();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        location.value = 'Location services are disabled';
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          location.value = 'Location permissions are denied';
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        location.value = 'Location permissions are permanently denied';
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('Error in _determinePosition: $e');
      location.value = 'Error getting location: $e';
      return Future.error('Error getting location: $e');
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      location.value = "Detecting...";
      Position position = await _determinePosition();
      debugPrint('Position obtained: ${position.latitude}, ${position.longitude}');
      await getAddressFromCoordinates(position);
    } catch (e) {
      debugPrint('Error getting location: $e');
      location.value = "Error: ${e.toString()}";
    }
  }

  Future<void> getAddressFromCoordinates(Position position) async {
  try {
    debugPrint('Getting address for: ${position.latitude}, ${position.longitude}');

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
      localeIdentifier: 'en_US',
    );

    if (placemarks.isEmpty) {
      throw Exception('No location data found');
    }

    Placemark place = placemarks[0];
    debugPrint('Raw Placemark Data: ${place.toString()}');

    // Tambahkan fallback untuk setiap field
    city.value = place.locality ?? 
                 place.subLocality ?? 
                 place.subAdministrativeArea ?? 
                 "Unknown City";
    
    province.value = place.administrativeArea ?? 
                    place.subAdministrativeArea ?? 
                    "Unknown Province";
    
    country.value = place.country ?? 
                   place.isoCountryCode ?? 
                   "Unknown Country";

    location.value = "${city.value}, ${province.value}, ${country.value}";
    
  } catch (e, stackTrace) {
    debugPrint('Error getting address: $e');
    debugPrint('Stack trace: $stackTrace');
    location.value = "Failed to get location details";
  }
}

  Future<void> checkUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      debugPrint('User: $user');
      currentUser.value = user as UserModel?;
    } catch (e) {
      debugPrint('Error getCurrentUser: $e');
      currentUser.value = null;
    }
  }

  Future<Map<String, dynamic>> clockIn({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    try {
      // Panggil repository attendance
      final result = await _attendanceRepository.clockIn(
        latitude: latitude,
        longitude: longitude,
        waktu: waktu,
      );
      debugPrint('Clock In Result: $result');
      return result;
    } catch (e) {
      debugPrint('Clock In Error: $e');
      return {
        'success': false,
        'message': 'Failed to clock in',
        'details': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> clockOut({
    required double latitude,
    required double longitude,
    required DateTime waktu,
  }) async {
    try {
      // Panggil repository attendance
      final result = await _attendanceRepository.clockOut(
        latitude: latitude,
        longitude: longitude,
        waktu: waktu,
      );
      debugPrint('Clock Out Result: $result');
      return result;
    } catch (e) {
      debugPrint('Clock Out Error: $e');
      return {
        'success': false,
        'message': 'Failed to clock out',
        'details': e.toString(),
      };
    }
  }

Future<Map<String, dynamic>> getTodayAttendance() async {
    try {
      final result = await _attendanceRepository.getTodayAttendance();
      debugPrint('Today Attendance: $result');
      return result;
    } catch (e) {
      debugPrint('Get Today Attendance Error: $e');
      return {
        'success': false,
        'message': 'Failed to get attendance status',
        'hasClockedIn': false,
        'hasClockedOut': true
      };
    }
  }
}
