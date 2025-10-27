import 'package:dji_mapper/core/drone_mapping_engine.dart';
import 'package:dji_mapper/shared/value_listeneables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child:
        Consumer<ValueListenables>(builder: (context, listenables, child) {
      var totalDistance = 0;
      var area = 0;
      var recommendedShutterSpeed = "0";
      if (listenables.polygon.length > 2) {
        var mainDistance = DroneMappingEngine.calculateTotalDistance(
            listenables.flightLine?.points ?? []);
        var takeoffDistance = DroneMappingEngine.calculateTotalDistance(
            listenables.takeoffLine?.points ?? []);
        var returnDistance = DroneMappingEngine.calculateTotalDistance(
            listenables.returnLine?.points ?? []);
        totalDistance = (mainDistance + takeoffDistance + returnDistance).round();
        area = DroneMappingEngine.calculateArea(listenables.polygon).round();
        recommendedShutterSpeed =
          DroneMappingEngine.calculateRecommendedShutterSpeed(
            altitude: listenables.altitude - listenables.groundOffset,
            sensorWidth: listenables.sensorWidth,
            focalLength: listenables.focalLength,
            imageWidth: listenables.imageWidth,
            droneSpeed: listenables.speed,
          );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
              title: const Text("Create Photo Points"),
              value: listenables.createCameraPoints,
              onChanged: (value) {
                setState(() {
                  listenables.createCameraPoints = value;
                });
              }),
          SwitchListTile(
              title: Text((listenables.createCameraPoints)?"Show Photo Points":"Show Waypoints" ),
              value: listenables.showPoints,
              onChanged: (value) {
                setState(() {
                  listenables.showPoints = value;
                });
              }),
          SwitchListTile(
              title: const Text("Fill Grid"),
              value: listenables.fillGrid,
              onChanged: (value) {
                setState(() {
                  listenables.fillGrid = value;
                });
              }),
          Card(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if(listenables.createCameraPoints)
                Text("Number of photos: ${listenables.photoLocations.length}",
                    style: const TextStyle(fontSize: 16))
              else
                Text("Number of waypoints: ${listenables.photoLocations.length}",
                    style: const TextStyle(fontSize: 16)),
              const Divider(),
              Text("Flight distance: $totalDistance m",
                  style: const TextStyle(fontSize: 16)),
              const Divider(),
              Text("Area: $area m²", style: const TextStyle(fontSize: 16)),
              const Divider(),
              Text(
                  "Estimated flight time: ${(((totalDistance / listenables.speed) + (listenables.photoLocations.length * listenables.delayAtWaypoint)) / 60).round()} minutes",
                  style: const TextStyle(fontSize: 16)),
              const Divider(),
              Text(
                  "Recommended shutter speed: $recommendedShutterSpeed or faster",
                  style: const TextStyle(fontSize: 16)),
            ]),
          ))
        ],
      );
    }));
  }
}
