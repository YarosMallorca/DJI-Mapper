import 'package:dji_mapper/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LitchiLoadAlert extends StatefulWidget {
  const LitchiLoadAlert({super.key, this.showCheckbox = true});

  /// Whether to show the "Do not show again" checkbox.
  ///
  /// Defaults to `true`.
  final bool showCheckbox;

  @override
  State<LitchiLoadAlert> createState() => _LitchiLoadAlertState();
}

class _LitchiLoadAlertState extends State<LitchiLoadAlert> {
  bool _doNotShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Load mission into Litchi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Step 1", style: TextStyle(fontWeight: FontWeight.bold)),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  const TextSpan(text: '• Go to '),
                  TextSpan(
                    text: 'Litchi Mission Hub',
                    style: const TextStyle(
                      color: Colors.blue,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap =
                          () => launchUrl(Uri.https('flylitchi.com', '/hub')),
                  ),
                  const TextSpan(text: ' and log in.'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text("Step 2", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text(
                "• Set the settings correctly, highlighted in blue are the important settings."),
            const SizedBox(height: 4),
            Image.asset(
              'assets/litchi_alert/settings.jpg',
              width: 400,
            ),
            const SizedBox(height: 4),
            const Text(
              "The Finish Action should be set the same as in the DJI Mapper",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),
            const Text("Step 3", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text(
                "• Click on the 'Missions -> Import' and select the mission file."),
            const SizedBox(height: 4),
            Image.asset('assets/litchi_alert/import.jpg', width: 150),
            const SizedBox(height: 10),
            const Text("Step 4", style: TextStyle(fontWeight: FontWeight.bold)),
            const Text(
                "• Save the mission with a name and it will automatically sync to your device."),
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
                prefs.setBool("litchiWarningDoNotShow", _doNotShowAgain);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ],
    );
  }
}
