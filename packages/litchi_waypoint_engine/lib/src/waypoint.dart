import 'package:litchi_waypoint_engine/src/action.dart';

import 'enums.dart';
import 'poi.dart';

class Waypoint {
  /// Latitude coordinate for the waypoint in WGS84 format
  final double latitude;

  /// Longitude coordinate for the waypoint in WGS84 format
  final double longitude;

  /// Altitude for the waypoint in meters
  final int altitude;

  /// Speed for the waypoint in m/s
  final int speed;

  /// Heading for the waypoint in degrees
  final double? heading;

  /// Curvesize (radius?) in meters
  final double curveSize;

  /// Direction of rotation
  final RotationDirection rotationDirection;

  /// Gimbal mode
  final GimbalMode gimbalMode;

  /// Gimbal pitch in degrees
  final int gimbalPitch;

  /// Either use AGL or MSL for altitude
  ///
  /// If not specified, the default is AGL
  final AltitudeMode altitudeMode;

  /// POI for the waypoint
  final Poi? poi;

  /// Actions for the waypoint
  final List<Action>? actions;

  /// Time interval for photos in milliseconds
  ///
  /// If not specified, it will be disabled
  final double? photoTimeInterval;

  /// Distance interval for photos
  ///
  /// If not specified, it will be disabled
  final double? photoDistanceInterval;

  const Waypoint(
      {required this.latitude,
      required this.longitude,
      required this.altitude,
      required this.speed,
      this.heading,
      this.curveSize = 0,
      this.rotationDirection = RotationDirection.clockwise,
      this.gimbalMode = GimbalMode.interpolate,
      this.gimbalPitch = 0,
      this.altitudeMode = AltitudeMode.agl,
      this.poi,
      this.actions,
      this.photoTimeInterval,
      this.photoDistanceInterval})
      : assert(!(gimbalMode != GimbalMode.interpolate && gimbalPitch != 0),
            'Gimbal pitch can only be set when gimbal mode is interpolate'),
        assert(!(photoTimeInterval != null && photoDistanceInterval != null),
            'Only one of photoTimeInterval or photoDistanceInterval can be set'),
        assert(gimbalPitch >= -90 && gimbalPitch <= 60,
            'Gimbal pitch must be between -90 and 60');
}
