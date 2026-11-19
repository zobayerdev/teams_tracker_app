import 'dart:developer';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionResult {
  final bool isSuccess;
  final String? errorMessage;
  final bool isPermanentlyDenied;
  final bool isServiceDisabled;

  const LocationPermissionResult({
    required this.isSuccess,
    this.errorMessage,
    this.isPermanentlyDenied = false,
    this.isServiceDisabled = false,
  });

  factory LocationPermissionResult.success() =>
      const LocationPermissionResult(isSuccess: true);

  factory LocationPermissionResult.serviceDisabled() =>
      const LocationPermissionResult(
        isSuccess: false,
        isServiceDisabled: true,
        errorMessage: 'GPS is turned off. Tap to enable.',
      );

  factory LocationPermissionResult.denied() => const LocationPermissionResult(
    isSuccess: false,
    errorMessage: 'Location permission required. Tap to allow.',
  );

  factory LocationPermissionResult.permanentlyDenied() =>
      const LocationPermissionResult(
        isSuccess: false,
        isPermanentlyDenied: true,
        errorMessage: 'Permission denied. Tap to open Settings.',
      );
}

final class LocationHelper {
  static final LocationHelper _instance = LocationHelper._internal();
  LocationHelper._internal();
  static LocationHelper get instance => _instance;

  final Geocoding _geocoding = Geocoding();

  /// Check if GPS is enabled and immediately trigger permission popup if needed
  Future<LocationPermissionResult> checkAndRequestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationPermissionResult.denied();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionResult.permanentlyDenied();
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionResult.serviceDisabled();
      }

      return LocationPermissionResult.success();
    } on PermissionDefinitionsNotFoundException catch (e) {
      log('Manifest/Plist permission missing: $e');
      return const LocationPermissionResult(
        isSuccess: false,
        errorMessage: 'Location permission missing in Manifest.',
      );
    } catch (e) {
      log('Location permission error: $e');
      return const LocationPermissionResult(
        isSuccess: false,
        errorMessage: 'Location permission not granted. Tap to retry.',
      );
    }
  }

  /// Get the current accurate pinpoint GPS position
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: const Duration(seconds: 15),
        ),
      );
    } catch (e) {
      log('Error getting current position: $e');
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Get a real-time live position stream for continuous accurate tracking
  Stream<Position> getLivePositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 5,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Convert coordinates into human-readable address
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await _geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[];

        if (place.street != null &&
            place.street!.trim().isNotEmpty &&
            !place.street!.contains('+')) {
          parts.add(place.street!.trim());
        } else if (place.name != null &&
            place.name!.trim().isNotEmpty &&
            !place.name!.contains('+')) {
          parts.add(place.name!.trim());
        }

        if (place.subLocality != null && place.subLocality!.trim().isNotEmpty) {
          if (!parts.contains(place.subLocality!.trim())) {
            parts.add(place.subLocality!.trim());
          }
        }

        if (place.locality != null && place.locality!.trim().isNotEmpty) {
          if (!parts.contains(place.locality!.trim())) {
            parts.add(place.locality!.trim());
          }
        }

        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
    } catch (e) {
      log('Reverse geocoding error: $e');
    }
    return null;
  }

  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
