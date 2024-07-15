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
      if (listenables.polygon.length > 2) {
        totalDistance = DroneMappingEngine.calculateTotalDistance(
                listenables.flightLine?.points ?? [])
            .round();
        area = DroneMappingEngine.calculateArea(listenables.polygon).round();
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
              title: const Text("Show Camera Locations"),
              value: listenables.showCameras,
              onChanged: (value) {
                setState(() {
                  listenables.showCameras = value;
                });
              }),
          Card(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("Number of photos: ${listenables.photoLocations.length}",
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
            ]),
          ))
        ],
      );
    }));
  }
}
