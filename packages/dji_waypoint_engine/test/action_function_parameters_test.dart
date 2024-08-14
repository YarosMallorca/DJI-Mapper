import 'package:dji_waypoint_engine/engine.dart';
import 'package:test/test.dart';

void main() {
  group('CameraControlParams', () {
    test(
        'should create CameraControlParams instance with correct payloadPosition',
        () {
      final params = CameraControlParams(payloadPosition: 1);
      expect(params.payloadPosition, 1);
    });
  });

  group('GimbalRotateParams', () {
    test(
        'should create GimbalRotateParams instance with correct pitch and payloadPosition',
        () {
      final params = GimbalRotateParams(pitch: 45.0, payloadPosition: 2);
      expect(params.pitch, 45.0);
      expect(params.payloadPosition, 2);
    });
  });

  group('HoverParams', () {
    test('should create HoverParams instance with correct hoverTime', () {
      final params = HoverParams(hoverTime: 5);
      expect(params.hoverTime, 5);
    });

    test('should throw an assertion error when hoverTime is 0', () {
      expect(() => HoverParams(hoverTime: 0), throwsA(isA<AssertionError>()));
    });
  });
}
