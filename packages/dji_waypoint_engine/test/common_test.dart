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

  group('DroneInfo', () {
    test('should create DroneInfo instance with correct droneEnumValue', () {
      final droneInfo = DroneInfo(droneEnumValue: 89);
      expect(droneInfo.droneEnumValue, 89);
    });

    test(
        'should create DroneInfo instance with correct droneEnumValue and droneSubEnumValue',
        () {
      final droneInfo = DroneInfo(droneEnumValue: 67, droneSubEnumValue: 1);
      expect(droneInfo.droneEnumValue, 67);
      expect(droneInfo.droneSubEnumValue, 1);
    });
  });

  group('MissionConfig', () {
    test('should create MissionConfig instance with correct parameters', () {
      final droneInfo = DroneInfo(droneEnumValue: 89);
      final missionConfig = MissionConfig(
        flyToWaylineMode: FlyToWaylineMode.safely,
        finishAction: FinishAction.noAction,
        exitOnRCLost: ExitOnRCLost.executeLostAction,
        rcLostAction: RCLostAction.hover,
        globalTransitionalSpeed: 10.0,
        droneInfo: droneInfo,
      );

      expect(missionConfig.flyToWaylineMode, FlyToWaylineMode.safely);
      expect(missionConfig.finishAction, FinishAction.noAction);
      expect(missionConfig.exitOnRCLost, ExitOnRCLost.executeLostAction);
      expect(missionConfig.rcLostAction, RCLostAction.hover);
      expect(missionConfig.globalTransitionalSpeed, 10.0);
      expect(missionConfig.droneInfo, droneInfo);
    });
  });
}
