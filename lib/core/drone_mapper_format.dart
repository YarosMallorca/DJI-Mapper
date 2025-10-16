import 'package:geoxml/geoxml.dart';
import 'package:xml/xml.dart';

class DroneMapperXml extends GeoXml {
  DroneMapperXml();

  @override
  String get version => "1.0";

  @override
  String get creator => "DroneMapper";

  @override
  Metadata get metadata => Metadata(
      name: "DroneMapper Mission", desc: "Mission created by DroneMapper");

  static Future<DroneMapperXml> fromKmlString(String kml) async {
    final flattenedKml = _flattenKml(kml);
    GeoXml geoXml = await GeoXml.fromKmlString(flattenedKml);
    var dmXml = DroneMapperXml();
    dmXml.polygons = geoXml.polygons;
    return dmXml;
  }
}

/// Flatten KML by removing wrappers because of bug in GeoXML parser:
/// https://github.com/sun-jiao/geoxml/issues/5
String _flattenKml(String kml) {
  final doc = XmlDocument.parse(kml);

  // Unwrap a tag but preserve its children
  void unwrapElements(String tagName) {
    for (final element in doc.findAllElements(tagName).toList()) {
      final parent = element.parent;
      if (parent != null) {
        // Create deep copies of the children before moving them
        final clonedChildren = element.children.map((c) => c.copy()).toList();

        final index = parent.children.indexOf(element);
        parent.children.replaceRange(index, index + 1, clonedChildren);
      }
    }
  }

  // Unwrap common KML wrappers
  unwrapElements('MultiGeometry');
  unwrapElements('Folder');

  return doc.toXmlString(pretty: false);
}
