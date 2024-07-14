import 'dart:io';

import 'package:dji_waypoint_engine/engine.dart';

void main() {
  var missionConfig = MissionConfig(
      flyToWaylineMode: FlyToWaylineMode.safely,
      finishAction: FinishAction.goHome,
      rcLostAction: RCLostAction.goBack,
      exitOnRCLost: ExitOnRCLost.executeLostAction,
      globalTransitionalSpeed: 10,
      droneInfo: DroneInfo(droneEnumValue: 68));

  var template = TemplateKml(
      document: KmlDocumentElement(
    missionConfig: missionConfig,
    author: "fly",
    creationTime: DateTime.now(),
    modificationTime: DateTime.now(),
  ));

  var waypoint = WaylinesWpml(
      document: WpmlDocumentElement(
          missionConfig: missionConfig,
          folderElement: FolderElement(
              templateId: 0,
              waylineId: 0,
              distance: 100,
              duration: 10,
              speed: 8,
              placemarks: [
                Placemark(
                    index: 0,
                    height: 50,
                    speed: 8,
                    useStraightLine: false,
                    headingParam: HeadingParam(
                        headingMode: HeadingMode.followWayline,
                        headingPathMode: HeadingPathMode.followBadArc,
                        headingAngleEnable: false),
                    turnParam: TurnParam(
                        waypointTurnMode: WaypointTurnMode.coordinateTurn,
                        turnDampingDistance: 0),
                    point: WaypointPoint(
                        longitude: 3.366615, latitude: 39.585863)),
                Placemark(
                    index: 0,
                    height: 50,
                    speed: 8,
                    useStraightLine: false,
                    headingParam: HeadingParam(
                        headingMode: HeadingMode.followWayline,
                        headingPathMode: HeadingPathMode.followBadArc,
                        headingAngleEnable: false),
                    turnParam: TurnParam(
                        waypointTurnMode: WaypointTurnMode.coordinateTurn,
                        turnDampingDistance: 0),
                    point: WaypointPoint(
                        longitude: 3.356615, latitude: 39.545863)),
              ])));

  createDJIFile(
      template: template, waylines: waypoint, filePath: File("test.kmz"));
}
