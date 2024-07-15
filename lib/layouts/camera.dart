import 'package:dji_mapper/components/text_field.dart';
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

  late CameraPreset _selectedPreset;

  @override
  void initState() {
    super.initState();
    _presets = PresetManager.getPresets();
    _selectedPreset = _presets[0];
  }

  void _updatePreset(ValueListenables listenables) {
    PresetManager.updatePreset(
        _presets.indexOf(_selectedPreset),
        CameraPreset(
            name: _selectedPreset.name,
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
    _selectedPreset = newPreset;
    listenables.notify();
    Navigator.pop(context);
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
                    value: _selectedPreset,
                    items: List.generate(
                        _presets.length,
                        (i) => DropdownMenuItem(
                              value: _presets[i],
                              child: Text(_presets[i].name),
                            )),
                    onChanged: (item) {
                      _selectedPreset = item ?? _presets[0];

                      // Update listenables
                      listenables.sensorWidth = _selectedPreset.sensorWidth;
                      listenables.sensorHeight = _selectedPreset.sensorHeight;
                      listenables.focalLength = _selectedPreset.focalLength;
                      listenables.imageWidth = _selectedPreset.imageWidth;
                      listenables.imageHeight = _selectedPreset.imageHeight;
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
                  onPressed: _selectedPreset.defaultPreset
                      ? null
                      : () {
                          final int previousIndex =
                              _presets.indexOf(_selectedPreset);
                          PresetManager.deletePreset(_selectedPreset);
                          _presets = PresetManager.getPresets();
                          _selectedPreset = _presets[previousIndex - 1];
                          listenables.notify();
                        },
                  icon: const Icon(Icons.delete),
                  tooltip: _selectedPreset.defaultPreset
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
                      enabled: !_selectedPreset.defaultPreset,
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
                      enabled: !_selectedPreset.defaultPreset,
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
                      enabled: !_selectedPreset.defaultPreset,
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
                        _presets[_presets.indexOf(_selectedPreset)].imageWidth =
                            px.toInt();
                        PresetManager.updatePreset(
                            _presets.indexOf(_selectedPreset),
                            _presets[_presets.indexOf(_selectedPreset)]);
                      },
                      defaultValue: listenables.imageWidth.toDouble(),
                      enabled: !_selectedPreset.defaultPreset,
                    ),
                    CustomTextField(
                      labelText: "Image Height (px)",
                      min: 300,
                      max: 10000,
                      defaultValue: listenables.imageHeight.toDouble(),
                      onChanged: (px) {
                        listenables.imageHeight = px.toInt();
                        _presets[_presets.indexOf(_selectedPreset)]
                            .imageHeight = px.toInt();
                      },
                      enabled: !_selectedPreset.defaultPreset,
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
