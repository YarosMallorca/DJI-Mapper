import 'package:dji_mapper/shared/aircraft_settings.dart';
import 'package:dji_waypoint_engine/engine.dart';
import 'package:dji_mapper/components/text_field.dart';
import 'package:dji_mapper/shared/value_listeneables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AircraftBar extends StatefulWidget {
  const AircraftBar({super.key});

  @override
  State<AircraftBar> createState() => _AircraftBarState();
}

class _AircraftBarState extends State<AircraftBar> {
  @override
  void initState() {
    final listenables = Provider.of<ValueListenables>(context, listen: false);

    final settings = AircraftSettings.getAircraftSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      listenables.altitude = settings.altitude;
      listenables.speed = settings.speed;
      listenables.forwardOverlap = settings.forwardOverlap;
      listenables.sideOverlap = settings.sideOverlap;
      listenables.rotation = settings.rotation;
      listenables.delayAtWaypoint = settings.delay;
      listenables.cameraAngle = settings.cameraAngle;
      listenables.onFinished = settings.finishAction;
      listenables.rcLostAction = settings.rcLostAction;
    });

    super.initState();
  }

  void _updateSettings(ValueListenables listenables) {
    AircraftSettings.saveAircraftSettings(AircraftSettings(
      altitude: listenables.altitude,
      speed: listenables.speed,
      forwardOverlap: listenables.forwardOverlap,
      sideOverlap: listenables.sideOverlap,
      rotation: listenables.rotation,
      delay: listenables.delayAtWaypoint,
      cameraAngle: listenables.cameraAngle,
      finishAction: listenables.onFinished,
      rcLostAction: listenables.rcLostAction,
    ));
  }

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
                        onChanged: (m) {
                          listenables.altitude = m.round();
                          _updateSettings(listenables);
                        },
                        defaultValue: listenables.altitude),
                    CustomTextField(
                        labelText: "Speed (m/s)",
                        min: 0.1,
                        max: 9,
                        defaultValue: listenables.speed,
                        onChanged: (speed) {
                          listenables.speed = speed;
                          _updateSettings(listenables);
                        },
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
                      defaultValue: listenables.forwardOverlap,
                      onChanged: (percent) {
                        listenables.forwardOverlap = percent.round();
                        _updateSettings(listenables);
                      },
                    ),
                    CustomTextField(
                      labelText: "Sidelap (%)",
                      min: 1,
                      max: 90,
                      defaultValue: listenables.sideOverlap,
                      onChanged: (percent) {
                        listenables.sideOverlap = percent.round();
                        _updateSettings(listenables);
                      },
                    ),
                    CustomTextField(
                      labelText: "Rotation (deg)",
                      min: 0,
                      max: 360,
                      defaultValue: listenables.rotation,
                      onChanged: (degrees) {
                        listenables.rotation = degrees.round();
                        _updateSettings(listenables);
                      },
                    ),
                    CustomTextField(
                      labelText: "Camera angle (deg)",
                      min: -90,
                      max: 0,
                      defaultValue: listenables.cameraAngle,
                      onChanged: (degrees) {
                        listenables.cameraAngle = degrees.round();
                        _updateSettings(listenables);
                      },
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
                defaultValue: listenables.delayAtWaypoint,
                onChanged: (delaySeconds) {
                  listenables.delayAtWaypoint = delaySeconds.round();
                  _updateSettings(listenables);
                },
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
                            _updateSettings(listenables);
                          }),
                      ChoiceChip(
                          label: const Text('RTH'),
                          selected:
                              listenables.onFinished == FinishAction.goHome,
                          onSelected: (bool selected) {
                            setState(() {
                              listenables.onFinished = FinishAction.goHome;
                            });
                            _updateSettings(listenables);
                          }),
                      ChoiceChip(
                          label: const Text('Land'),
                          selected:
                              listenables.onFinished == FinishAction.autoLand,
                          onSelected: (bool selected) {
                            setState(() {
                              listenables.onFinished = FinishAction.autoLand;
                            });
                            _updateSettings(listenables);
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
                            _updateSettings(listenables);
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
                            _updateSettings(listenables);
                          }),
                      ChoiceChip(
                          label: const Text('RTH'),
                          selected:
                              listenables.rcLostAction == RCLostAction.goBack,
                          onSelected: (bool selected) {
                            setState(() {
                              listenables.rcLostAction = RCLostAction.goBack;
                            });
                            _updateSettings(listenables);
                          }),
                      ChoiceChip(
                          label: const Text('Land'),
                          selected:
                              listenables.rcLostAction == RCLostAction.landing,
                          onSelected: (bool selected) {
                            setState(() {
                              listenables.rcLostAction = RCLostAction.landing;
                            });
                            _updateSettings(listenables);
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
