import 'package:litchi_waypoint_engine/engine.dart';
import 'package:test/test.dart';

void main() {
  group('LitchiCsv', () {
    test('generateCsv returns correct CSV content', () {
      List<Waypoint> waypoints = [
        Waypoint(
            latitude: 37.7749,
            longitude: -122.4194,
            altitude: 100,
            heading: 90,
            curveSize: 10,
            rotationDirection: RotationDirection.clockwise,
            gimbalMode: GimbalMode.disabled,
            actions: [
              Action(actionType: ActionType.takePhoto, actionParam: 1),
              Action(actionType: ActionType.startRecording, actionParam: 0),
            ],
            altitudeMode: AltitudeMode.agl,
            speed: 5,
            poi: const Poi(
                latitude: 37.7749, longitude: -122.4194, altitude: 50),
            photoTimeInterval: 10),
        Waypoint(
          latitude: 37.7749,
          longitude: -122.4194,
          altitude: 200,
          curveSize: 5,
          rotationDirection: RotationDirection.counterClockwise,
          gimbalMode: GimbalMode.focusPoi,
          actions: [
            Action(actionType: ActionType.stopRecording, actionParam: 0),
          ],
          altitudeMode: AltitudeMode.msl,
          speed: 10,
        ),
      ];

      String expectedCsvContent =
          'latitude,longitude,altitude(m),heading(deg),curvesize(m),rotationdir,gimbalmode,gimbalpitchangle,actiontype1,actionparam1,actiontype2,actionparam2,altitudemode,speed(m/s),poi_latitude,poi_longitude,poi_altitude(m),poi_altitudemode,photo_timeinterval,photo_distinterval\r\n37.7749,-122.4194,100,90.0,10.0,0,0,0,1,1.0,2,0.0,0,5,37.7749,-122.4194,50,0,10.0,-1\r\n37.7749,-122.4194,200,0,5.0,1,1,0,3,0.0,-1,0,1,10,0,0,0,1,-1,-1';

      expect(LitchiCsv.generateCsv(waypoints), equals(expectedCsvContent));
    });

    test('generateCsv returns empty CSV content for empty waypoints list', () {
      List<Waypoint> waypoints = [];

      String expectedCsvContent =
          'latitude,longitude,altitude(m),heading(deg),curvesize(m),rotationdir,gimbalmode,gimbalpitchangle,altitudemode,speed(m/s),poi_latitude,poi_longitude,poi_altitude(m),poi_altitudemode,photo_timeinterval,photo_distinterval';

      expect(LitchiCsv.generateCsv(waypoints), equals(expectedCsvContent));
    });
  });
}
