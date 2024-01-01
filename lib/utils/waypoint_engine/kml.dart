import 'package:xml/xml.dart';
import 'enums.dart';

class KML {
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
      builder.element('wpml:author', nest: () {
        builder.text("DJI Waypoint Mapping");
      });
      builder.xml(missionConfig());
    });
    return builder.buildDocument().toXmlString();
  }
}

class MissionConfig {
  final FinishAction finishAction;
  final RCLostAction rcLostAction;
  final int speed;

  MissionConfig({
    required this.rcLostAction,
    required this.finishAction,
    required this.speed,
  });

  String call() {
    XmlBuilder builder = XmlBuilder();
    builder.element('wpml:missionConfig', nest: () {
      builder.element('wpml:flyToWaylineMode', nest: () {
        builder.text("safely");
      });
      builder.element('wpml:finishAction', nest: () {
        builder.text(finishAction.name);
      });
      builder.element('wpml:exitOnRCLost', nest: () {
        builder.text("executeLostAction");
      });
      builder.element('wpml:executeRCLostAction', nest: () {
        builder.text(rcLostAction.name);
      });
      builder.element('wpml:globalTransitionalSpeed', nest: () {
        builder.text(speed.toString());
      });
    });
    return builder.buildDocument().toXmlString();
  }
}
