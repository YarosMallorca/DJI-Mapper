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
        name: "DJI Air 3 (50 MP)",
        defaultPreset: true,
        sensorWidth: 9.65,
        sensorHeight: 7.24,
        focalLength: 6.72,
        imageWidth: 8064,
        imageHeight: 6048),
    CameraPreset(
        name: "DJI Air 3S (12 MP)",
        defaultPreset: true,
        sensorWidth: 13.2,
        sensorHeight: 8.8,
        focalLength: 8.67,
        imageWidth: 4032,
        imageHeight: 3024),
    CameraPreset(
        name: "DJI Air 3S (48 MP)",
        defaultPreset: true,
        sensorWidth: 13.2,
        sensorHeight: 8.8,
        focalLength: 8.67,
        imageWidth: 8192,
        imageHeight: 6144),
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
        name: "DJI Mini 4 Pro (12 MP)",
        defaultPreset: true,
        sensorWidth: 9.7,
        sensorHeight: 7.3,
        focalLength: 6.88,
        imageWidth: 4032,
        imageHeight: 3024),
    CameraPreset(
        name: "DJI Mini 4 Pro (48 MP)",
        defaultPreset: true,
        sensorWidth: 9.7,
        sensorHeight: 7.3,
        focalLength: 6.88,
        imageWidth: 8064,
        imageHeight: 6048),
    CameraPreset(
        name: "DJI Mini 5 Pro (12MP)",
        defaultPreset: true,
        sensorWidth: 13.2,
        sensorHeight: 8.8,
        focalLength: 9.0,
        imageWidth: 4098,
        imageHeight: 3072),
    CameraPreset(
        name: "DJI Mini 5 Pro (48 MP)",
        defaultPreset: true,
        sensorWidth: 13.2,
        sensorHeight: 8.8,
        focalLength: 9.0,
        imageWidth: 8192,
        imageHeight: 6144),
    CameraPreset(
        name: "DJI Mavic 2 Pro",
        defaultPreset: true,
        sensorWidth: 13.2,
        sensorHeight: 8.8,
        focalLength: 10.3,
        imageWidth: 5472,
        imageHeight: 3648),
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
  ];

  /// Migrates old preset storage format and sets up the new system
  ///
  /// Removes default presets from SharedPreferences if they exist
  static void init() {
    _migrateOldPresets();
  }

  /// Migrates from the old system where all presets were saved
  /// to the new system where only custom presets are saved
  static void _migrateOldPresets() {
    final String? oldPresetsJson = prefs.getString("cameraPresets");

    if (oldPresetsJson != null) {
      try {
        final List<dynamic> oldPresetsList = jsonDecode(oldPresetsJson);
        final List<CameraPreset> oldPresets = oldPresetsList
            .map<CameraPreset>((preset) => CameraPreset.fromJson(preset))
            .toList();

        // Filter out default presets, keeping only custom ones
        final List<CameraPreset> customPresets =
            oldPresets.where((preset) => !preset.defaultPreset).toList();

        // Save only custom presets
        _saveCustomPresets(customPresets);
        prefs.remove("cameraPresets");
      } catch (e) {
        // If migration fails, clear the old data
        prefs.remove("cameraPresets");
      }
    }
  }

  /// Returns all presets: default presets first, then custom presets
  static List<CameraPreset> getPresets() {
    final List<CameraPreset> allPresets = List.from(_defaultPresets);
    allPresets.addAll(getCustomPresets());
    return allPresets;
  }

  /// Returns only custom presets from SharedPreferences
  static List<CameraPreset> getCustomPresets() {
    return jsonDecode(prefs.getString("customCameraPresets") ?? "[]")
        .map<CameraPreset>((preset) => CameraPreset.fromJson(preset))
        .toList();
  }

  /// Saves only custom presets to SharedPreferences
  static void _saveCustomPresets(List<CameraPreset> customPresets) {
    prefs.setString("customCameraPresets",
        jsonEncode(customPresets.map((preset) => preset.toJson()).toList()));
  }

  static void addPreset(CameraPreset preset) {
    // Only add if it's a custom preset
    if (preset.defaultPreset) {
      throw Exception("Cannot add default preset - they are built-in");
    }

    var customPresets = getCustomPresets();
    customPresets.add(preset);
    _saveCustomPresets(customPresets);
  }

  static void deletePreset(CameraPreset preset) {
    if (preset.defaultPreset) throw Exception("Cannot delete default preset");

    var customPresets = getCustomPresets();
    customPresets.removeWhere((p) => p.name == preset.name);
    _saveCustomPresets(customPresets);
  }

  static void updatePreset(int index, CameraPreset newPreset) {
    var allPresets = getPresets();

    if (index >= allPresets.length) {
      throw Exception("Invalid preset index");
    }

    if (allPresets[index].defaultPreset) {
      throw Exception("Cannot update default preset");
    }

    // Calculate the index in the custom presets list
    var customIndex = index - _defaultPresets.length;
    var customPresets = getCustomPresets();

    if (customIndex < 0 || customIndex >= customPresets.length) {
      throw Exception("Invalid custom preset index");
    }

    customPresets[customIndex] = newPreset;
    _saveCustomPresets(customPresets);
  }
}
