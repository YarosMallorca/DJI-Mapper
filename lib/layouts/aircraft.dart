import 'package:dji_waypoint_mapping/components/text_field.dart';
import 'package:flutter/material.dart';

class AircraftBar extends StatefulWidget {
  const AircraftBar({super.key});

  @override
  State<AircraftBar> createState() => _AircraftBarState();
}

class _AircraftBarState extends State<AircraftBar> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(labelText: "Altitude (m)", min: 1, max: 500, defaultValue: 50),
                  CustomTextField(labelText: "Angle (deg)", min: 0, max: 360, defaultValue: 0),
                  CustomTextField(labelText: "Speed (m/s)", min: 0.1, max: 9, defaultValue: 4.0, decimal: true),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(labelText: "Overlap (%)", min: 1, max: 90, defaultValue: 80),
                  CustomTextField(labelText: "Sidelap (%)", min: 1, max: 90, defaultValue: 60),
                ],
              ),
            ),
          ),
          Card(
            child: CustomTextField(labelText: "Delay at Waypoint (sec)", min: 0, max: 10, defaultValue: 0),
          )
        ],
      ),
    );
  }
}
