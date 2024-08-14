import 'dart:io';

import 'package:litchi_waypoint_engine/engine.dart';

void main() {
  var waypoints = [
    const Waypoint(
        latitude: 39.582095944969154,
        longitude: 3.377013508806934,
        altitude: 30,
        speed: 6),
    const Waypoint(
        latitude: 39.58324787135231,
        longitude: 3.377717912315177,
        altitude: 30,
        speed: 6),
    const Waypoint(
        latitude: 39.583437196034645,
        longitude: 3.37712893627256,
        altitude: 30,
        speed: 6),
    const Waypoint(
        latitude: 39.582319488614814,
        longitude: 3.3765251618876313,
        altitude: 30,
        speed: 6),
  ];

  createLitchiFile(waypoints: waypoints, filePath: File("waypoints.csv"));
}
