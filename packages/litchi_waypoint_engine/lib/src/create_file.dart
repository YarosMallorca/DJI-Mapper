import 'dart:io';
import 'package:litchi_waypoint_engine/engine.dart';

Future<File> createLitchiFile(
    {required List<Waypoint> waypoints, required File filePath}) async {
  var csvContent = LitchiCsv.generateCsv(waypoints);
  await filePath.writeAsString(csvContent);
  return File(filePath.path);
}
