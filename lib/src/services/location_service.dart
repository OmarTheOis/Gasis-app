import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult.failure('locationServicesDisabled');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const LocationResult.failure('locationPermissionDenied');
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationResult.failure('locationPermissionForeverDenied');
    }

    final position = await Geolocator.getCurrentPosition();

    return LocationResult.success(
      LatLng(position.latitude, position.longitude),
    );
  }
}

class LocationResult {
  const LocationResult._({
    required this.location,
    required this.errorKey,
  });

  const LocationResult.success(LatLng value)
      : this._(
          location: value,
          errorKey: null,
        );

  const LocationResult.failure(String key)
      : this._(
          location: null,
          errorKey: key,
        );

  final LatLng? location;
  final String? errorKey;

  bool get isSuccess => location != null;
}
