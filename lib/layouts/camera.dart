import 'package:dji_mapper/components/text_field.dart';
import 'package:dji_mapper/shared/value_listeneables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CameraBar extends StatefulWidget {
  const CameraBar({super.key});

  @override
  State<CameraBar> createState() => _CameraBarState();
}

class _CameraBarState extends State<CameraBar> {
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
                        labelText: "Sensor Width (mm)",
                        min: 1,
                        max: 50,
                        onChanged: (mm) => listenables.sensorWidth = mm,
                        defaultValue: listenables.sensorWidth,
                        decimal: true),
                    CustomTextField(
                        labelText: "Sensor Height (mm)",
                        min: 1,
                        max: 50,
                        defaultValue: listenables.sensorHeight,
                        onChanged: (mm) => listenables.sensorHeight = mm,
                        decimal: true),
                    CustomTextField(
                        labelText: "Focal Length (mm)",
                        min: 1,
                        max: 50,
                        defaultValue: listenables.focalLength,
                        onChanged: (mm) => listenables.focalLength = mm,
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
                        labelText: "Image Width (px)",
                        min: 300,
                        max: 10000,
                        onChanged: (px) => listenables.imageWidth = px.toInt(),
                        defaultValue: listenables.imageWidth.toDouble()),
                    CustomTextField(
                        labelText: "Image Height (px)",
                        min: 300,
                        max: 10000,
                        defaultValue: listenables.imageHeight.toDouble(),
                        onChanged: (px) =>
                            listenables.imageHeight = px.toInt()),
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
