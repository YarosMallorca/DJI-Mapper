import 'package:test/test.dart';
import 'package:litchi_waypoint_engine/src/waypoint.dart';
import 'package:litchi_waypoint_engine/src/action.dart';
import 'package:litchi_waypoint_engine/src/enums.dart';
import 'package:litchi_waypoint_engine/src/poi.dart';

void main() {
  group('Waypoint', () {
    test('Waypoint properties are set correctly', () {
      final waypoint = Waypoint(
        latitude: 37.7749,
        longitude: -122.4194,
        altitude: 100,
        speed: 10,
        heading: 90.0,
        curveSize: 5.0,
        rotationDirection: RotationDirection.counterClockwise,
        gimbalMode: GimbalMode.interpolate,
        gimbalPitch: -30,
        altitudeMode: AltitudeMode.msl,
        poi: const Poi(latitude: 37.7749, longitude: -122.4194, altitude: 50),
        actions: [
          Action(actionType: ActionType.takePhoto),
          Action(actionType: ActionType.startRecording),
        ],
        photoTimeInterval: 5000.0,
      );

      expect(waypoint.latitude, equals(37.7749));
      expect(waypoint.longitude, equals(-122.4194));
      expect(waypoint.altitude, equals(100));
      expect(waypoint.speed, equals(10));
      expect(waypoint.heading, equals(90.0));
      expect(waypoint.curveSize, equals(5.0));
      expect(waypoint.rotationDirection,
          equals(RotationDirection.counterClockwise));
      expect(waypoint.gimbalMode, equals(GimbalMode.interpolate));
      expect(waypoint.gimbalPitch, equals(-30));
      expect(waypoint.altitudeMode, equals(AltitudeMode.msl));
      expect(waypoint.photoTimeInterval, equals(5000.0));
    });

    test(
        'Waypoint throws an exception when Gimbal pitch is set and gimbal mode is not interpolate',
        () {
      expect(
        () => Waypoint(
            latitude: 37.7749,
            longitude: -122.4194,
            altitude: 100,
            speed: 10,
            gimbalMode: GimbalMode.focusPoi,
            gimbalPitch: -30),
        throwsA(isA<AssertionError>()),
      );
    });

    test('Waypoint throws an exception when gimbal pitch is out of range', () {
      expect(
        () => Waypoint(
          latitude: 37.7749,
          longitude: -122.4194,
          altitude: 100,
          speed: 10,
          gimbalPitch: 90,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test(
        'Waypoint throws an exception when both photoTimeInterval and photoDistanceInterval are set',
        () {
      expect(
        () => Waypoint(
          latitude: 37.7749,
          longitude: -122.4194,
          altitude: 100,
          speed: 10,
          photoTimeInterval: 5000.0,
          photoDistanceInterval: 10.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
