import 'package:xml/xml.dart';
import 'kml.dart';
import 'enums.dart';

class WPML {
  XmlDocument buildKml({required RCLostAction rcLostAction, required int speed}) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element("kml",
        attributes: {"xmlns": "http://www.opengis.net/kml/2.2", "xmlns:wpml": "http://www.dji.com/wpmz/1.0.2"},
        nest: () {
      builder.xml(Document(
          missionConfig:
              MissionConfig(rcLostAction: RCLostAction.goBack, finishAction: FinishAction.goHome, speed: 10))());
    });

    return builder.buildDocument();
  }
}

class Document {
  final MissionConfig missionConfig;
  final XmlBuilder builder = XmlBuilder();

  Document({required this.missionConfig});

  String call() {
    builder.element('Document', nest: () {
      builder.xml(missionConfig());
    });
    return builder.buildDocument().toXmlString();
  }
}

class Folder {
  final int templateId;
  final int waylineId;
  final int distance;
  final int duration;
  final double autoFlightSpeed;
  final List<Placemark> placemarks;

  Folder(
      {required this.templateId,
      required this.waylineId,
      this.distance = 0,
      this.duration = 0,
      required this.autoFlightSpeed,
      required this.placemarks});

  String call() {
    XmlBuilder builder = XmlBuilder();
    builder.element('Folder', nest: () {
      builder.element('wpml:templateId', nest: () {
        builder.text(templateId);
      });
      builder.element('wpml:executeHeightMode', nest: () {
        builder.text("relativeToStartPoint");
      });
      builder.element('wpml:waylineId', nest: () {
        builder.text(waylineId);
      });
      builder.element('wpml:distance', nest: () {
        builder.text(distance);
      });
      builder.element('wpml:duration', nest: () {
        builder.text(duration);
      });
      builder.element('wpml:autoFlightSpeed', nest: () {
        builder.text(autoFlightSpeed);
      });
      for (var placemark in placemarks) {
        builder.xml(placemark());
      }
    });
    return builder.buildDocument().toXmlString();
  }
}

class Placemark {
  final Point point;
  final int index;
  final int height;
  final double speed;
  final HeadingParameters headingParameters;
  final TurnParameters turnParameters;
  final bool useStraightLine;
  final ActionGroup actions;

  Placemark(
      {required this.point,
      required this.index,
      required this.height,
      required this.speed,
      required this.headingParameters,
      required this.turnParameters,
      required this.useStraightLine,
      required this.actions});

  String call() {
    XmlBuilder builder = XmlBuilder();
    builder.element('Placemark', nest: () {
      builder.xml(point());
      builder.element('wpml:index', nest: () {
        builder.text(index);
      });
      builder.element('wpml:executeHeight', nest: () {
        builder.text(height);
      });
      builder.element('wpml:waypointSpeed', nest: () {
        builder.text(speed);
      });
      builder.xml(headingParameters());
      builder.xml(turnParameters());
      builder.element('wpml:useStraightLine', nest: () {
        builder.text(useStraightLine ? 1 : 0);
      });
      builder.xml(actions());
    });
    return builder.buildDocument().toXmlString();
  }
}

class Point {
  final double latitude;
  final double longitude;

  Point({required this.latitude, required this.longitude});

  String call() {
    XmlBuilder builder = XmlBuilder();
    builder.element('Point', nest: () {
      builder.element('coordinates', nest: () {
        builder.text("$longitude,$latitude");
      });
    });
    return builder.buildDocument().toXmlString();
  }
}

class HeadingParameters {
  final HeadingMode headingMode;
  final double headingAngle;
  final PoiPoint poiPoint;
  final bool headingAngleEnabled;
  final HeadingPathMode headingPathMode;

  HeadingParameters(
      {required this.headingMode,
      required this.headingAngle,
      required this.poiPoint,
      required this.headingAngleEnabled,
      required this.headingPathMode});

  String call() {
    XmlBuilder builder = XmlBuilder();
    builder.element('wpml:headingParameters', nest: () {
      builder.element('wpml:headingMode', nest: () {
        builder.text(headingMode.name);
      });
      builder.element('wpml:headingAngle', nest: () {
        builder.text(headingAngle);
      });
      builder.xml(poiPoint());
      builder.element('wpml:headingAngleEnabled', nest: () {
        builder.text(headingAngleEnabled);
      });
      builder.element('wpml:headingPathMode', nest: () {
        builder.text(headingPathMode.name);
      });
    });
    return builder.buildDocument().toXmlString();
  }
}

class TurnParameters {
  final WaypointTurnMode waypointTurnMode;
  final double waypointTurnDampingDistance;

  TurnParameters({required this.waypointTurnMode, required this.waypointTurnDampingDistance});

  String call() {
    XmlBuilder builder = XmlBuilder();
    builder.element('wpml:turnParameters', nest: () {
      builder.element('wpml:waypointTurnMode', nest: () {
        builder.text(waypointTurnMode.name);
      });
      builder.element('wpml:waypointTurnDampingDist', nest: () {
        builder.text(waypointTurnDampingDistance);
      });
    });
    return builder.buildDocument().toXmlString();
  }
}

class PoiPoint {
  final double latitude;
  final double longitude;
  final int altitude;

  PoiPoint({required this.latitude, required this.longitude, required this.altitude});

  String call() {
    XmlBuilder builder = XmlBuilder();
    builder.element('wpml:poiPoint', nest: () {
      builder.text("$longitude,$latitude,$altitude");
    });
    return builder.buildDocument().toXmlString();
  }
}

class ActionGroup {
  final int id;
  final int startWaypoint;
  final int endWaypoint;
  final ActionMode actionMode;
  final ActionTrigger actionTrigger;
  final Action action;

  ActionGroup(
      {required this.id,
      required this.startWaypoint,
      required this.endWaypoint,
      required this.actionMode,
      required this.actionTrigger,
      required this.action});

  String call() {
    XmlBuilder builder = XmlBuilder();
    builder.element('wpml:actionGroup', nest: () {
      builder.element('wpml:id', nest: () {
        builder.text(id);
      });
      builder.element('wpml:startWaypoint', nest: () {
        builder.text(startWaypoint);
      });
      builder.element('wpml:endWaypoint', nest: () {
        builder.text(endWaypoint);
      });
      builder.element('wpml:actionMode', nest: () {
        builder.text(actionMode.name);
      });
      builder.xml(actionTrigger());
      builder.xml(action());
    });
    return builder.buildDocument().toXmlString();
  }
}

class ActionTrigger {
  final ActionTriggerType triggerType;
  final double? triggerParam;

  ActionTrigger({required this.triggerType, this.triggerParam});

  String call() {
    XmlBuilder builder = XmlBuilder();
    builder.element('wpml:actionTrigger', nest: () {
      builder.element('wpml:actionTriggerType', nest: () {
        builder.text(triggerType.name);
      });
      if (triggerParam != null) {
        builder.element('wpml:actionTriggerParam', nest: () {
          builder.text(triggerParam!);
        });
      }
    });
    return builder.buildDocument().toXmlString();
  }
}

class Action {
  final int id;
  final ActionFunction function;
  final Map params;

  Action({required this.id, required this.function, required this.params});

  String call() {
    XmlBuilder builder = XmlBuilder();
    builder.element('wpml:action', nest: () {
      builder.element('wpml:actionId', nest: () {
        builder.text(id);
      });
      builder.element('wpml:actionActuatorFunc', nest: () {
        builder.text(function.name);
      });
      if (params.isNotEmpty) {
        builder.element('wpml:actionActuatorFuncParam', nest: () {
          params.forEach((key, value) {
            builder.element("wpml:$key", nest: () {
              builder.text(value);
            });
          });
        });
      }
    });
    return builder.buildDocument().toXmlString();
  }
}
