import 'package:geoxml/geoxml.dart';

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
    GeoXml geoXml = await GeoXml.fromKmlString(kml);
    var dmXml = DroneMapperXml();
    dmXml.polygons = geoXml.polygons;
    return dmXml;
  }
}
