import 'package:dji_waypoint_engine/engine.dart';
import 'package:dji_waypoint_mapping/components/text_field.dart';
import 'package:dji_waypoint_mapping/shared/value_listeneables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AircraftBar extends StatefulWidget {
  const AircraftBar({super.key});

  @override
  State<AircraftBar> createState() => _AircraftBarState();
}

class _AircraftBarState extends State<AircraftBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ValueListenables>(builder: (context, listenables, child) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                        labelText: "Altitude (m)",
                        min: 10,
                        max: 500,
                        onChanged: (m) => listenables.altitude = m.round(),
                        defaultValue: listenables.altitude.toDouble()),
                    CustomTextField(
                        labelText: "Speed (m/s)",
                        min: 0.1,
                        max: 9,
                        defaultValue: listenables.speed,
                        onChanged: (speed) => listenables.speed = speed,
                        decimal: true),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      labelText: "Overlap (%)",
                      min: 1,
                      max: 90,
                      defaultValue: listenables.forwardOverlap.toDouble(),
                      onChanged: (percent) =>
                          listenables.forwardOverlap = percent.round(),
                    ),
                    CustomTextField(
                      labelText: "Sidelap (%)",
                      min: 1,
                      max: 90,
                      defaultValue: listenables.sideOverlap.toDouble(),
                      onChanged: (percent) =>
                          listenables.sideOverlap = percent.round(),
                    ),
                    CustomTextField(
                      labelText: "Rotation (deg)",
                      min: 0,
                      max: 360,
                      defaultValue: listenables.rotation.toDouble(),
                      onChanged: (degrees) =>
                          listenables.rotation = degrees.round(),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: CustomTextField(
                labelText: "Delay at Waypoint (sec)",
                min: 0,
                max: 10,
                defaultValue: listenables.delayAtWaypoint.toDouble(),
                onChanged: (delaySeconds) =>
                    listenables.delayAtWaypoint = delaySeconds.round(),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    const Align(
                      child: Text(
                        "On Finished:",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(spacing: 5.0, runSpacing: 5.0, children: [
                      ChoiceChip(
                          label: const Text('Hover'),
                          selected:
                              listenables.onFinished == FinishAction.noAction,
                          onSelected: (bool selected) {
                            setState(() {
                              listenables.onFinished = FinishAction.noAction;
                            });
                          }),
                      ChoiceChip(
                          label: const Text('RTH'),
                          selected:
                              listenables.onFinished == FinishAction.goHome,
                          onSelected: (bool selected) {
                            setState(() {
                              listenables.onFinished = FinishAction.goHome;
                            });
                          }),
                      ChoiceChip(
                          label: const Text('Land'),
                          selected:
                              listenables.onFinished == FinishAction.autoLand,
                          onSelected: (bool selected) {
                            setState(() {
                              listenables.onFinished = FinishAction.autoLand;
                            });
                          }),
                      ChoiceChip(
                          label: const Text('Go to first waypoint'),
                          selected: listenables.onFinished ==
                              FinishAction.gotoFirstWaypoint,
                          onSelected: (bool selected) {
                            setState(() {
                              listenables.onFinished =
                                  FinishAction.gotoFirstWaypoint;
                            });
                          })
                    ]),
                    const Divider(),
                    const SizedBox(height: 10),
                    const Align(
                      child: Text(
                        "On Signal Loss:",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(spacing: 5.0, runSpacing: 5.0, children: [
                      ChoiceChip(
                          label: const Text('Hover'),
                          selected:
                              listenables.rcLostAction == RCLostAction.hover,
                          onSelected: (bool selected) {
                            setState(() {
                              listenables.rcLostAction = RCLostAction.hover;
                            });
                          }),
                      ChoiceChip(
                          label: const Text('RTH'),
                          selected:
                              listenables.rcLostAction == RCLostAction.goBack,
                          onSelected: (bool selected) {
                            setState(() {
                              listenables.rcLostAction = RCLostAction.goBack;
                            });
                          }),
                      ChoiceChip(
                          label: const Text('Land'),
                          selected:
                              listenables.rcLostAction == RCLostAction.landing,
                          onSelected: (bool selected) {
                            setState(() {
                              listenables.rcLostAction = RCLostAction.landing;
                            });
                          }),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
