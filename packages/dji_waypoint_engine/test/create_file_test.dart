import 'dart:io';
import 'package:test/test.dart';
import 'package:dji_waypoint_engine/engine.dart';

void main() {
  group('createDJIFile', () {
    test('should create a DJI file with the correct content', () async {
      // Arrange
      final missionConfig = MissionConfig(
          flyToWaylineMode: FlyToWaylineMode.safely,
          finishAction: FinishAction.autoLand,
          exitOnRCLost: ExitOnRCLost.executeLostAction,
          rcLostAction: RCLostAction.goBack,
          globalTransitionalSpeed: 5.0,
          droneInfo: DroneInfo(droneEnumValue: 68));
      final template = TemplateKml(
          document: KmlDocumentElement(
              author: "fly",
              creationTime: DateTime.now(),
              modificationTime: DateTime.now(),
              missionConfig: missionConfig));
      final waylines = WaylinesWpml(
          document: WpmlDocumentElement(
              missionConfig: missionConfig,
              folderElement: FolderElement(
                  templateId: 0,
                  waylineId: 0,
                  speed: 5,
                  placemarks: [
                    Placemark(
                        point: WaypointPoint(longitude: 123, latitude: 456),
                        index: 0,
                        height: 20,
                        speed: 10,
                        headingParam: HeadingParam(
                            headingMode: HeadingMode.fixed,
                            headingPathMode: HeadingPathMode.clockwise),
                        turnParam: TurnParam(
                            turnDampingDistance: 0,
                            waypointTurnMode: WaypointTurnMode
                                .toPointAndPassWithContinuityCurvature),
                        useStraightLine: false)
                  ])));
      final filePath = File('test.kmz');

      // Act
      final result = await createDJIFile(
        template: template,
        waylines: waylines,
        filePath: filePath,
      );

      // Assert
      expect(result.existsSync(), isTrue);

      // Clean up
      await result.delete();
    });
  });
}
