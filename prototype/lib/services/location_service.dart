import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum LocationFailure {
  servicesDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.failure);

  final LocationFailure failure;
}

class LocationService {
  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(LocationFailure.servicesDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        LocationFailure.permissionPermanentlyDenied,
      );
    }
    if (permission == LocationPermission.denied) {
      throw const LocationServiceException(LocationFailure.permissionDenied);
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      ).timeout(const Duration(seconds: 25));
    } on LocationServiceDisabledException {
      throw const LocationServiceException(LocationFailure.servicesDisabled);
    }
  }
}
