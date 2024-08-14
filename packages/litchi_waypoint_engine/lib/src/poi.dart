import 'package:litchi_waypoint_engine/src/enums.dart';

class Poi {
  /// Latitude coordinate for the POI in WGS84 format
  final double latitude;

  /// Longitude coordinate for the POI in WGS84 format
  final double longitude;

  /// Altitude for the POI in meters
  final int altitude;

  /// Either use AGL or MSL for altitude
  final AltitudeMode altitudeMode;

  const Poi({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    this.altitudeMode = AltitudeMode.agl,
  });
}
