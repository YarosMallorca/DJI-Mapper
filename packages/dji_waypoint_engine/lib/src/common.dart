import 'package:xml/xml.dart';

import 'enums.dart';

/// Aircraft type information
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/common-element.html#wpml-droneinfo
class DroneInfo extends XmlElement {
  /// Drone type
  ///
  /// According to DJI Docs:
  ///
  /// 89 (M350 RTK)
  ///
  /// 60 (M300 RTK)
  ///
  /// 67 (M30/M30T)
  ///
  /// 77（M3E/M3T/M3M
  ///
  /// 91（M3D/M3TD）
  final int droneEnumValue;

  /// Drone sub type
  /// 0 (default)
  ///
  /// According to DJI Docs:
  ///
  /// when droneEnumValue is 67:
  ///
  /// 0 (M30),
  ///
  /// 1 (M30T)
  ///
  /// <hr>
  ///
  /// when droneEnumValue is 77:
  ///
  /// 0 (M3E)
  ///
  /// 1 (M3T)
  ///
  /// 2 (M3M)
  ///
  ///<hr>
  ///
  /// when droneEnumValue is 91:
  ///
  /// 0 (M3D)
  ///
  /// 1 (M3TD)
  ///
  /// 2 (M3M)
  final int droneSubEnumValue;

  DroneInfo({required this.droneEnumValue, this.droneSubEnumValue = 0})
      : super(XmlName("wpml:droneInfo"), [], [
          XmlElement.tag(
            "wpml:droneEnumValue",
            children: [XmlText(droneEnumValue.toString())],
          ),
          XmlElement.tag(
            "wpml:droneSubEnumValue",
            children: [XmlText(droneSubEnumValue.toString())],
          ),
        ]);
}

/// Mission information
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/template-kml.html#mission-information-parent-element-wpml-missionconfig
class MissionConfig extends XmlElement {
  /// Fly to first waypoint mode
  final FlyToWaylineMode flyToWaylineMode;

  /// The action when finish mission
  final FinishAction finishAction;

  /// Whether to continue to execute the route out of control
  final ExitOnRCLost exitOnRCLost;

  /// Type of disconnect action
  final RCLostAction rcLostAction;

  /// The speed at which the aircraft flies to the first waypoint of each route.
  /// When the route mission is interrupted, the speed of the aircraft recovering
  /// from the current position to the interruption point.
  final double globalTransitionalSpeed;

  /// Aircraft type information
  final DroneInfo droneInfo;

  MissionConfig({
    required this.flyToWaylineMode,
    required this.finishAction,
    required this.exitOnRCLost,
    required this.rcLostAction,
    required this.globalTransitionalSpeed,
    required this.droneInfo,
  }) : super(
          XmlName("wpml:missionConfig"),
          [], // No attributes
          [
            XmlElement.tag("wpml:flyToWaylineMode", children: [
              XmlText(flyToWaylineMode.name),
            ]),
            XmlElement.tag(
              "wpml:finishAction",
              children: [XmlText(finishAction.name)],
            ),
            XmlElement.tag(
              "wpml:exitOnRCLost",
              children: [XmlText(exitOnRCLost.name)],
            ),
            XmlElement.tag(
              "wpml:executeRCLostAction",
              children: [XmlText(rcLostAction.name)],
            ),
            XmlElement.tag(
              "wpml:globalTransitionalSpeed",
              children: [XmlText(globalTransitionalSpeed.toString())],
            ),
            droneInfo
          ],
        );
}
