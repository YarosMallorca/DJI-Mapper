import 'package:dji_mapper/components/text_field.dart';
import 'package:dji_mapper/main.dart';
import 'package:dji_mapper/presets/camera_preset.dart';
import 'package:dji_mapper/presets/preset_manager.dart';
import 'package:dji_mapper/shared/value_listeneables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CameraBar extends StatefulWidget {
  const CameraBar({super.key});

  @override
  State<CameraBar> createState() => _CameraBarState();
}

class _CameraBarState extends State<CameraBar> {
  late List<CameraPreset> _presets;

  @override
  void initState() {
    super.initState();
    _presets = PresetManager.getPresets();

    final listenables = Provider.of<ValueListenables>(context, listen: false);

    // Load the latest preset
    var latestPresetName = prefs.getString("latestPreset");
    if (latestPresetName == null) {
      latestPresetName = _presets[0].name;
      prefs.setString("latestPreset", latestPresetName);
    }

    // Select the latest preset
    listenables.selectedCameraPreset = _presets.firstWhere(
        (element) => element.name == latestPresetName,
        orElse: () => _presets[0]);

    // Update listenables
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateProvider(listenables);
    });
  }

  void _updatePreset(ValueListenables listenables) {
    PresetManager.updatePreset(
        _presets.indexOf(listenables.selectedCameraPreset!),
        CameraPreset(
            name: listenables.selectedCameraPreset!.name,
            defaultPreset: false,
            sensorWidth: listenables.sensorWidth,
            sensorHeight: listenables.sensorHeight,
            focalLength: listenables.focalLength,
            imageWidth: listenables.imageWidth,
            imageHeight: listenables.imageHeight));
  }

  /// Always called from the `AlertDialog`
  void _addPreset(
      ValueListenables listenables, TextEditingController nameController) {
    final CameraPreset newPreset = CameraPreset(
        defaultPreset: false,
        name: nameController.text,
        sensorWidth: listenables.sensorWidth,
        sensorHeight: listenables.sensorHeight,
        focalLength: listenables.focalLength,
        imageWidth: listenables.imageWidth,
        imageHeight: listenables.imageHeight);
    PresetManager.addPreset(newPreset);
    _presets = PresetManager.getPresets();
    Provider.of<ValueListenables>(context, listen: false).selectedCameraPreset =
        newPreset;
    listenables.notify();
    // Update latest preset
    prefs.setString("latestPreset", listenables.selectedCameraPreset!.name);
    Navigator.pop(context);
  }

  void _updateProvider(ValueListenables listenables) {
    listenables.sensorWidth = listenables.selectedCameraPreset!.sensorWidth;
    listenables.sensorHeight = listenables.selectedCameraPreset!.sensorHeight;
    listenables.focalLength = listenables.selectedCameraPreset!.focalLength;
    listenables.imageWidth = listenables.selectedCameraPreset!.imageWidth;
    listenables.imageHeight = listenables.selectedCameraPreset!.imageHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ValueListenables>(builder: (context, listenables, child) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text("Camera Preset:"),
                const SizedBox(width: 10),
                DropdownButton(
                    value: listenables.selectedCameraPreset,
                    items: List.generate(
                        _presets.length,
                        (i) => DropdownMenuItem(
                              value: _presets[i],
                              child: Text(_presets[i].name),
                            )),
                    onChanged: (item) {
                      listenables.selectedCameraPreset = item ?? _presets[0];

                      // Update listenables
                      _updateProvider(listenables);

                      // Update latest preset
                      prefs.setString("latestPreset",
                          listenables.selectedCameraPreset!.name);
                    }),
                const SizedBox(
                  width: 6,
                ),
                IconButton(
                  onPressed: () {
                    final nameController = TextEditingController();
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text("Preset Title"),
                              content: TextField(
                                autocorrect: false,
                                autofocus: true,
                                onChanged: (text) {
                                  nameController.text = text;
                                },
                                onSubmitted: (value) =>
                                    _addPreset(listenables, nameController),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel")),
                                TextButton(
                                    onPressed: () =>
                                        _addPreset(listenables, nameController),
                                    child: const Text("Save")),
                              ],
                            ));
                  },
                  icon: const Icon(Icons.add),
                  tooltip: "Add",
                ),
                IconButton(
                  onPressed: listenables.selectedCameraPreset!.defaultPreset
                      ? null
                      : () {
                          final int previousIndex = _presets
                              .indexOf(listenables.selectedCameraPreset!);
                          PresetManager.deletePreset(
                              listenables.selectedCameraPreset!);
                          _presets = PresetManager.getPresets();
                          listenables.selectedCameraPreset =
                              _presets[previousIndex - 1];
                          prefs.setString(
                            "latestPreset",
                            listenables.selectedCameraPreset!.name,
                          );
                          listenables.notify();
                        },
                  icon: const Icon(Icons.delete),
                  tooltip: listenables.selectedCameraPreset!.defaultPreset
                      ? "Can't delete default preset"
                      : "Delete",
                ),
              ],
            ),
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
                      onChanged: (mm) {
                        listenables.sensorWidth = mm;
                        _updatePreset(listenables);
                      },
                      defaultValue: listenables.sensorWidth,
                      decimal: true,
                      enabled: !listenables.selectedCameraPreset!.defaultPreset,
                    ),
                    CustomTextField(
                      labelText: "Sensor Height (mm)",
                      min: 1,
                      max: 50,
                      defaultValue: listenables.sensorHeight,
                      onChanged: (mm) {
                        listenables.sensorHeight = mm;
                        _updatePreset(listenables);
                      },
                      decimal: true,
                      enabled: !listenables.selectedCameraPreset!.defaultPreset,
                    ),
                    CustomTextField(
                      labelText: "Focal Length (mm)",
                      min: 1,
                      max: 50,
                      defaultValue: listenables.focalLength,
                      onChanged: (mm) {
                        listenables.focalLength = mm;
                        _updatePreset(listenables);
                      },
                      decimal: true,
                      enabled: !listenables.selectedCameraPreset!.defaultPreset,
                    ),
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
                      onChanged: (px) {
                        listenables.imageWidth = px.toInt();
                        _updatePreset(listenables);
                      },
                      defaultValue: listenables.imageWidth.toDouble(),
                      enabled: !listenables.selectedCameraPreset!.defaultPreset,
                    ),
                    CustomTextField(
                      labelText: "Image Height (px)",
                      min: 300,
                      max: 10000,
                      defaultValue: listenables.imageHeight.toDouble(),
                      onChanged: (px) {
                        listenables.imageHeight = px.toInt();
                        _updatePreset(listenables);
                      },
                      enabled: !listenables.selectedCameraPreset!.defaultPreset,
                    ),
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
