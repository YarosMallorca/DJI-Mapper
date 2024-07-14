import 'package:dji_waypoint_engine/src/common.dart';
import 'package:xml/xml.dart';

/// The `template.kml` file consists of three parts:
///
/// Creation information: It mainly contains the information of the route file itself,
/// such as the creation and update time of the file.
///
/// Mission information: mainly includes the wpml:missionConfig element,
/// which defines the global parameters of the route mission, etc.
///
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/template-kml.html#file-introduction
class TemplateKml extends XmlDocument {
  final KmlDocumentElement document;
  TemplateKml({required this.document})
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
/// https://developer.dji.com/doc/cloud-api-tutorial/en/api-reference/dji-wpml/template-kml.html#element-description
class KmlDocumentElement extends XmlElement {
  /// The author of the file.
  final String author;

  /// The creation time of the file (Unix timestamp).
  final DateTime creationTime;

  /// The update time of the file (Unix timestamp).
  final DateTime modificationTime;

  /// The mission information
  final MissionConfig missionConfig;

  KmlDocumentElement({
    required this.author,
    required this.creationTime,
    required this.modificationTime,
    required this.missionConfig,
  }) : super(
          XmlName("Document"),
          [], // No attributes
          [
            XmlElement.tag(
              "wpml:author",
              children: [XmlText(author)],
            ),
            XmlElement.tag(
              "wpml:createTime",
              children: [
                XmlText(creationTime.millisecondsSinceEpoch.toString())
              ],
            ),
            XmlElement.tag(
              "wpml:updateTime",
              children: [
                XmlText(modificationTime.millisecondsSinceEpoch.toString())
              ],
            ),
            missionConfig
          ],
        );
}
