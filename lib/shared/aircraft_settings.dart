import 'dart:convert';

import 'package:dji_mapper/main.dart';
import 'package:dji_waypoint_engine/engine.dart';

class AircraftSettings {
  int altitude;
  double speed;
  int forwardOverlap;
  int sideOverlap;
  int rotation;
  int delay;
  FinishAction finishAction;
  RCLostAction rcLostAction;

  AircraftSettings({
    required this.altitude,
    required this.speed,
    required this.forwardOverlap,
    required this.sideOverlap,
    required this.rotation,
    required this.delay,
    required this.finishAction,
    required this.rcLostAction,
  });

  Map<String, dynamic> toJson() {
    return {
      'altitude': altitude,
      'speed': speed,
      'forwardOverlap': forwardOverlap,
      'sideOverlap': sideOverlap,
      'rotation': rotation,
      'delay': delay,
      'finishAction': finishAction.name,
      'rcLostAction': rcLostAction.name,
    };
  }

  factory AircraftSettings.fromJson(Map<String, dynamic> json) {
    return AircraftSettings(
      altitude: json['altitude'],
      speed: json['speed'],
      forwardOverlap: json['forwardOverlap'],
      sideOverlap: json['sideOverlap'],
      rotation: json['rotation'],
      delay: json['delay'],
      finishAction: FinishAction.values.firstWhere(
          (e) => e.name == json['finishAction'],
          orElse: () => FinishAction.noAction),
      rcLostAction: RCLostAction.values.firstWhere(
          (e) => e.name == json['rcLostAction'],
          orElse: () => RCLostAction.hover),
    );
  }

  static final _defaultSettings = AircraftSettings(
    altitude: 50,
    speed: 5,
    forwardOverlap: 60,
    sideOverlap: 40,
    rotation: 0,
    delay: 0,
    finishAction: FinishAction.noAction,
    rcLostAction: RCLostAction.hover,
  );

  static AircraftSettings getAircraftSettings() {
    return AircraftSettings.fromJson(jsonDecode(
        prefs.getString("aircraftSettings") ??
            jsonEncode(_defaultSettings.toJson())));
  }

  static void saveAircraftSettings(AircraftSettings settings) {
    prefs.setString("aircraftSettings", jsonEncode(settings.toJson()));
  }
}