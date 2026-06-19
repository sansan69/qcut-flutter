import 'package:geolocator/geolocator.dart';

/// A simple lat/lng pair.
class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

/// Wraps the `geolocator` package so the rest of the app doesn't depend on
/// its permission/position APIs directly. All methods are graceful: if the
/// user denies location, the app keeps working with an unranked shop list.
class LocationService {
  /// Returns the device's current position, or `null` if location is
  /// unavailable/denied/service-disabled. Requests permission as needed.
  static Future<LatLng?> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // NB: geolocator 12.x uses [desiredAccuracy]/[timeLimit]; v13 renamed to
      // [locationSettings]. Keep this on the v12 API so both resolve.
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 8),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Great-circle distance in metres between two coordinates (haversine).
  /// Returns `null` if either side lacks coordinates.
  static double? distanceMeters({
    LatLng? from,
    double? fromLat,
    double? fromLng,
    double? toLat,
    double? toLng,
  }) {
    final aLat = from?.latitude ?? fromLat;
    final aLng = from?.longitude ?? fromLng;
    if (aLat == null || aLng == null || toLat == null || toLng == null) {
      return null;
    }
    return Geolocator.distanceBetween(aLat, aLng, toLat, toLng);
  }

  /// Human-friendly distance label: "< 1 km" or "X.X km".
  static String distanceLabel(double metres) {
    if (metres < 1000) return '${metres.round()} m';
    return '${(metres / 1000).toStringAsFixed(1)} km';
  }
}
