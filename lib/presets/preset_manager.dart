import 'dart:convert';

import 'package:dji_mapper/main.dart';
import 'package:dji_mapper/presets/camera_preset.dart';

class PresetManager {
  static final List<CameraPreset> _defaultPresets = [
    CameraPreset(
        name: "Mavic Air 2 (12 MP)",
        defaultPreset: true,
        sensorWidth: 6.35,
        sensorHeight: 4.94,
        focalLength: 4.8,
        imageWidth: 4000,
        imageHeight: 3000),
    CameraPreset(
        name: "Mavic Air 2S (3:4)",
        defaultPreset: true,
        sensorWidth: 13.05,
        sensorHeight: 8.82,
        focalLength: 9.18,
        imageWidth: 5472,
        imageHeight: 3648),
    CameraPreset(
        name: "DJI Air 3 (12 MP)",
        defaultPreset: true,
        sensorWidth: 9.65,
        sensorHeight: 7.24,
        focalLength: 6.72,
        imageWidth: 4032,
        imageHeight: 3024),
    CameraPreset(
        name: "DJI Mavic 2 Pro",
        defaultPreset: true,
        sensorWidth: 13.2,
        sensorHeight: 8.8,
        focalLength: 10.3,
        imageWidth: 5472,
        imageHeight: 3648),
    CameraPreset(
        name: "DJI Mini 3 Pro (12 MP)",
        defaultPreset: true,
        sensorWidth: 9.7,
        sensorHeight: 7.3,
        focalLength: 6.72,
        imageWidth: 4032,
        imageHeight: 3024),
    CameraPreset(
        name: "DJI Mini 3 Pro (48 MP)",
        defaultPreset: true,
        sensorWidth: 9.7,
        sensorHeight: 7.3,
        focalLength: 6.72,
        imageWidth: 8064,
        imageHeight: 6048),
    CameraPreset(
        name: "DJI Mavic 3E",
        defaultPreset: true,
        sensorWidth: 17.3,
        sensorHeight: 13,
        focalLength: 12.30,
        imageWidth: 5280,
        imageHeight: 3956),
    CameraPreset(
        name: "DJI Mavic 3T (RGB)",
        defaultPreset: true,
        sensorWidth: 6.4,
        sensorHeight: 4.8,
        focalLength: 4.4,
        imageWidth: 8000,
        imageHeight: 6000),
    CameraPreset(
        name: "DJI Mavic 3T (IR)",
        defaultPreset: true,
        sensorWidth: 7.68,
        sensorHeight: 6.14,
        focalLength: 9.10,
        imageWidth: 640,
        imageHeight: 512),
    CameraPreset(
        name: "DJI Air 3S",
        defaultPreset: true,
        sensorWidth: 13.2,
        sensorHeight: 8.8,
        focalLength: 24.00,
        imageWidth: 8192,
        imageHeight: 6144)
  ];

  /// Sets the default presets
  ///
  /// If the camera presets are already set, it does nothing
  static void init() {
    if (prefs.getString("cameraPresets") == null) {
      _savePresets(_defaultPresets);
    }
  }

  static List<CameraPreset> getPresets() {
    return jsonDecode(prefs.getString("cameraPresets") ?? "[]")
        .map<CameraPreset>((preset) => CameraPreset.fromJson(preset))
        .toList();
  }

  static void _savePresets(List<CameraPreset> presets) {
    prefs.setString("cameraPresets",
        jsonEncode(presets.map((preset) => preset.toJson()).toList()));
  }

  static void addPreset(CameraPreset preset) {
    var presets = getPresets();
    presets.add(preset);
    _savePresets(presets);
  }

  static void deletePreset(CameraPreset preset) {
    if (preset.defaultPreset) throw Exception("Cannot delete default preset");
    var presets = getPresets();
    presets.remove(preset);
    _savePresets(presets);
  }

  static void updatePreset(int index, CameraPreset newPreset) {
    var presets = getPresets();
    if (presets[index].defaultPreset) {
      throw Exception("Cannot update default preset");
    }
    presets[index] = newPreset;
    _savePresets(presets);
  }
}
