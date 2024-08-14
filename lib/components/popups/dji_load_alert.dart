import 'package:dji_mapper/main.dart';
import 'package:flutter/material.dart';

class DjiLoadAlert extends StatefulWidget {
  const DjiLoadAlert({super.key, this.showCheckbox = true});

  /// Whether to show the "Do not show again" checkbox.
  ///
  /// Defaults to `true`.
  final bool showCheckbox;

  @override
  State<DjiLoadAlert> createState() => _DjiLoadAlertState();
}

class _DjiLoadAlertState extends State<DjiLoadAlert> {
  bool _doNotShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Load mission into DJI Fly'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Step 1", style: TextStyle(fontWeight: FontWeight.bold)),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: const <TextSpan>[
                  TextSpan(
                      text: '• Open DJI Fly',
                      style: TextStyle(color: Colors.blue)),
                  TextSpan(
                      text:
                          ' - Create a new Mission [simple as 1wp] and save - '),
                  TextSpan(
                      text: 'Quit DJI Fly',
                      style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            const Text(
                "▪ [This will give it a recent date stamp making it easier to find & select]",
                style: TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            const Text("Step 2", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text("▪ iOS - Goto FILES/DJI Fly/wayline_mission/"),
            const Text(
                "▪ Android/DJI RC = Goto Android/data/dji.go.v5/files/waypoint"),
            const SizedBox(height: 4),
            const Text(
                """a) Select most recently created Mission Folder by date/time
b) Its name will be in the form of a GUID. Example: 6103D3C8-E79A-4B48-BBFE-50932D2E1306
c) Rename KMZ file that your importing to match the name of this mission on your device.
Example: 6103D3C8-E79A-4B48-BBFE-50932D2E1306.kmz
d) Upload the renamed KMZ into selected mission folder on your device replacing existing KMZ"""),
            const Text("Open DJI Fly",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text(
                "▪ Select the mission you just uploaded, should be on the top of the list"),
            const Text(
                "Examine all waypoints before you Fly to be sure they are configured as expected."),
            const SizedBox(height: 8),
            Text(
                "Do not modify or save the mission from inside DJI Fly, because it doesn't support straight curves, and will break the mission.",
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: widget.showCheckbox
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.end,
          children: [
            if (widget.showCheckbox)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox.adaptive(
                      value: _doNotShowAgain,
                      onChanged: (value) =>
                          setState(() => _doNotShowAgain = value!)),
                  GestureDetector(
                      onTap: () => setState(() {
                            _doNotShowAgain = !_doNotShowAgain;
                          }),
                      child: const Text("Do not show this again")),
                ],
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                prefs.setBool("djiWarningDoNotShow", _doNotShowAgain);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ],
    );
  }
}
