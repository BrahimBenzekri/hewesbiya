import 'dart:developer';

import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationService {
  // Check location permission status
  Future<LocationPermissionStatus> checkPermissionStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionStatus.deniedForever;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionStatus.granted;
      default:
        return LocationPermissionStatus.denied;
    }
  }

  // Request location permission
  Future<LocationPermissionStatus> requestLocation() async {
    log('[LocationService] requestLocation() called');
    
    log('[LocationService] Checking isLocationServiceEnabled()...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    log('[LocationService] isLocationServiceEnabled result: $serviceEnabled');
    
    if (!serviceEnabled) {
      log('[LocationService] Returning LocationPermissionStatus.serviceDisabled');
      return LocationPermissionStatus.serviceDisabled;
    }
    
    log('[LocationService] Calling Geolocator.requestPermission()...');
    LocationPermission permission = await Geolocator.requestPermission();
    log('[LocationService] Geolocator.requestPermission() returned: $permission');

    if (permission == LocationPermission.denied) {
      log('[LocationService] Returning LocationPermissionStatus.denied');
      return LocationPermissionStatus.denied;
    }

    if (permission == LocationPermission.deniedForever) {
      log('[LocationService] Returning LocationPermissionStatus.deniedForever');
      return LocationPermissionStatus.deniedForever;
    }

    log('[LocationService] Returning LocationPermissionStatus.granted');
    return LocationPermissionStatus.granted;
  }

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 30),
      ),
    );
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
