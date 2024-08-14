import 'common.dart';
import 'package:xml/xml.dart';

import 'enums.dart';

/// The `waylines.wpml` file consists of two parts.

/// Mission information: Contains mainly the wpml:missionConfig element,
/// which defines the global parameters of the waylines mission, etc.
///
/// Waylines information: Contains mainly Folder elements, which define detailed
/// waylines information (path definition, action definition, etc.).
/// Each Folder represents an executable route. In particular, when using the
/// "mapping3d" template, 5 executable routes are generated, corresponding to
/// the 5 Folder elements in waylines.wpml
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/waylines-wpml.html#file-introduction
class WaylinesWpml extends XmlDocument {
  final WpmlDocumentElement document;
  WaylinesWpml({required this.document})
      : super([
          XmlProcessing('xml', 'version="1.0" encoding="UTF-8"'),
          XmlElement(XmlName('kml'), [
            XmlAttribute(XmlName('xmlns'), 'http://www.opengis.net/kml/2.2'),
            XmlAttribute(
                XmlName('xmlns:wpml'), 'http://www.dji.com/wpmz/1.0.2'),
          ], [
            document
          ]),
        ]);
}

/// Create information
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/waylines-wpml.html
class WpmlDocumentElement extends XmlElement {
  /// The mission information
  final MissionConfig missionConfig;
  final FolderElement folderElement;

  WpmlDocumentElement({
    required this.missionConfig,
    required this.folderElement,
  }) : super(
          XmlName("Document"),
          [], // No attributes
          [missionConfig.copy(), folderElement.copy()],
        );
}

/// Create information
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/waylines-wpml.html
class FolderElement extends XmlElement {
  /// Waypoint number.
  ///
  /// Note: This ID is unique within a route.
  /// The sequence number must be monotonously and continuously increasing from 0.
  int templateId;

  int waylineId;

  /// Undocumented, but required, in DJI Fly missions
  /// it seems to be always 0
  int distance;

  /// Undocumented, but required, in DJI Fly missions
  /// it seems to be always 0
  int duration;

  /// in m/s
  double speed;
  List<Placemark> placemarks;

  FolderElement({
    required this.templateId,
    required this.waylineId,
    this.distance = 0,
    this.duration = 0,
    required this.speed,
    required this.placemarks,
  }) : super(
          XmlName("Folder"),
          [], // No attributes
          [
            XmlElement.tag(
              "wpml:templateId",
              children: [XmlText(templateId.toString())],
            ),
            XmlElement.tag(
              "wpml:executeHeightMode",

              /// Leaving this as a placeholder for now
              children: [XmlText("relativeToStartPoint")],
            ),
            XmlElement.tag(
              "wpml:waylineId",
              children: [XmlText(waylineId.toString())],
            ),
            XmlElement.tag(
              "wpml:distance",
              children: [XmlText(distance.toString())],
            ),
            XmlElement.tag(
              "wpml:duration",
              children: [XmlText(duration.toString())],
            ),
            XmlElement.tag(
              "wpml:autoFlightSpeed",
              children: [XmlText(speed.toString())],
            ),
            ...placemarks
          ],
        );
}

class Placemark extends XmlElement {
  final WaypointPoint point;
  final int index;
  final int height;
  final double speed;
  final HeadingParam headingParam;
  final TurnParam turnParam;
  final bool useStraightLine;
  final ActionGroup? actionGroup;

  Placemark({
    required this.point,
    required this.index,
    required this.height,
    required this.speed,
    required this.headingParam,
    required this.turnParam,
    required this.useStraightLine,
    this.actionGroup,
  }) : super(
          XmlName("Placemark"),
          [],
          [
            point,
            XmlElement.tag(
              "wpml:index",
              children: [XmlText(index.toString())],
            ),
            XmlElement.tag(
              "wpml:executeHeight",
              children: [XmlText(height.toString())],
            ),
            XmlElement.tag(
              "wpml:waypointSpeed",
              children: [XmlText(speed.toString())],
            ),
            headingParam,
            turnParam,
            XmlElement.tag(
              "wpml:useStraightLine",
              children: [XmlText(useStraightLine ? "1" : "0")],
            ),
            if (actionGroup != null) actionGroup,
          ],
        );
}

class WaypointPoint extends XmlElement {
  final double longitude;
  final double latitude;

  WaypointPoint({required this.longitude, required this.latitude})
      : super(
          XmlName("Point"),
          [],
          [
            XmlElement.tag(
              "coordinates",
              children: [
                XmlText("$longitude,$latitude"),
              ],
            ),
          ],
        );
}

class PoiPoint extends XmlElement {
  final double longitude;
  final double latitude;
  final double height;

  PoiPoint(
      {required this.longitude, required this.latitude, required this.height})
      : super(
          XmlName("wpml:waypointPoiPoint"),
          [],
          [
            XmlText(
                "${longitude.toStringAsFixed(6)},${latitude.toStringAsFixed(6)},${height.toStringAsFixed(6)}"),
          ],
        );
}

class HeadingParam extends XmlElement {
  final HeadingMode headingMode;

  /// The target yaw angle for a given waypoint and a uniform transition to the
  /// target yaw angle for the next waypoint over the course of the flight segment.
  final int? headingAngle;

  /// This field is only effective when wpml:waypointHeadingMode is set to towardPOI.
  ///
  /// When the [HeadingMode] for a specific waypoint is set to towardPOI,
  /// the aircraft's heading will face the point of interest while flying from that waypoint
  /// to the next waypoint.
  final PoiPoint? poiPoint;
  final HeadingPathMode headingPathMode;

  /// The target yaw angle for a given waypoint and a uniform transition to the
  /// target yaw angle for the next waypoint over the course of the flight segment.
  ///
  /// Only required if [headingMode] is set to `smoothTransition`
  final bool headingAngleEnable;

  HeadingParam({
    required this.headingMode,
    this.headingAngle,
    this.poiPoint,
    required this.headingPathMode,
    this.headingAngleEnable = false,
  }) : super(
          XmlName("wpml:waypointHeadingParam"),
          [],
          [
            XmlElement.tag(
              "wpml:waypointHeadingMode",
              children: [XmlText(headingMode.name)],
            ),
            XmlElement.tag(
              "wpml:waypointHeadingAngle",
              children: [
                XmlText(headingAngle != null ? headingMode.toString() : "0")
              ],
            ),
            poiPoint ??
                PoiPoint(
                    longitude: 0.000000, latitude: 0.000000, height: 0.000000),
            XmlElement.tag(
              "wpml:waypointHeadingAngleEnable",
              children: [XmlText(headingAngleEnable ? "1" : "0")],
            ),
            XmlElement.tag(
              "wpml:waypointHeadingPathMode",
              children: [XmlText(headingPathMode.name)],
            ),
          ],
        );
}

class TurnParam extends XmlElement {
  final WaypointTurnMode waypointTurnMode;

  /// (0, the maximum length of wayline segment] (unit: m)
  ///
  /// Note: The wayline segment between two waypoints should be greater than
  /// the sum of the turn intercepts of two waypoints.
  /// This element defines how far to the waypoint that the aircraft should turn.
  final int turnDampingDistance;

  TurnParam({
    required this.waypointTurnMode,
    required this.turnDampingDistance,
  }) : super(
          XmlName("wpml:waypointTurnParam"),
          [],
          [
            XmlElement.tag(
              "wpml:waypointTurnMode",
              children: [XmlText(waypointTurnMode.name)],
            ),
            XmlElement.tag(
              "wpml:waypointTurnDampingDist",
              children: [XmlText(turnDampingDistance.toString())],
            ),
          ],
        );
}

class ActionGroup extends XmlElement {
  /// action group Id
  ///
  /// Note: The ID is unique within a kmz file.
  ///
  /// It is recommended that it be monotonically and continuously incremented from 0.
  final int id;

  /// Waypoints where the action group starts to take effect.
  final int startIndex;

  /// Waypoints where the action group stops to take effect.
  ///
  /// Note: When the actionGroupStartIndex is the same as the actionGroupEndIndex,
  /// it means that the action group is only valid at that waypoint.
  final int endIndex;
  final ActionMode mode;
  final ActionTriggerType trigger;
  final List<Action> actions;

  ActionGroup(
      {required this.actions,
      required this.id,
      required this.startIndex,
      required this.endIndex,
      required this.mode,
      required this.trigger})
      : super(XmlName("wpml:actionGroup"), [], [
          XmlElement.tag(
            "wpml:actionGroupId",
            children: [XmlText(id.toString())],
          ),
          XmlElement.tag(
            "wpml:actionGroupStartIndex",
            children: [XmlText(startIndex.toString())],
          ),
          XmlElement.tag(
            "wpml:actionGroupEndIndex",
            children: [XmlText(endIndex.toString())],
          ),
          XmlElement.tag(
            "wpml:actionGroupMode",
            children: [XmlText(mode.name)],
          ),
          XmlElement.tag(
            "wpml:actionTrigger",
            children: [
              XmlElement.tag("wpml:actionTriggerType",
                  children: [XmlText(trigger.name)])
            ],
          ),
          ...actions,
        ]);
}

class Action extends XmlElement {
  final int id;
  final ActionFunction actionFunction;
  final Object actionParams;

  Action(
      {required this.id,
      required this.actionFunction,
      required this.actionParams})
      : super(XmlName("wpml:action"), [], [
          XmlElement.tag(
            "wpml:actionId",
            children: [XmlText(id.toString())],
          ),
          XmlElement.tag(
            "wpml:actionActuatorFunc",
            children: [XmlText(actionFunction.name)],
          ),
          actionParams as XmlNode
        ]);
}
