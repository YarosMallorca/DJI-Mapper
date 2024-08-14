import 'package:csv/csv.dart';
import 'package:litchi_waypoint_engine/src/action.dart';
import 'package:litchi_waypoint_engine/src/waypoint.dart';

import 'enums.dart';

class LitchiCsv {
  static String generateCsv(List<Waypoint> waypoints) {
    int maxActions = waypoints.fold(
        0,
        (prev, element) => prev > (element.actions ?? []).length
            ? prev
            : (element.actions ?? []).length);

    List<List<String>> csvContent = [
      [
        "latitude",
        "longitude",
        "altitude(m)",
        "heading(deg)",
        "curvesize(m)",
        "rotationdir",
        "gimbalmode",
        "gimbalpitchangle",
        // Generate action columns
        ...List.generate(maxActions,
                (i) => ["actiontype${i + 1}", "actionparam${i + 1}"])
            .expand((x) => x),
        "altitudemode",
        "speed(m/s)",
        "poi_latitude",
        "poi_longitude",
        "poi_altitude(m)",
        "poi_altitudemode",
        "photo_timeinterval",
        "photo_distinterval"
      ],
    ];

    for (Waypoint waypoint in waypoints) {
      List<String> row = [
        waypoint.latitude.toString(),
        waypoint.longitude.toString(),
        waypoint.altitude.toString(),
        waypoint.heading?.toString() ?? "0",
        waypoint.curveSize.toString(),
        // 0 = clockwise, 1 = counter-clockwise
        waypoint.rotationDirection == RotationDirection.clockwise ? "0" : "1",

        // 0 = disabled, 1 = focus POI, 2 = interpolate
        waypoint.gimbalMode == GimbalMode.disabled
            ? "0"
            : waypoint.gimbalMode == GimbalMode.focusPoi
                ? "1"
                : "2",
        waypoint.gimbalPitch.toString(),
        // Generate action values
        ...List.generate(maxActions, (i) {
          if (i < (waypoint.actions?.length ?? 0)) {
            return [
              Action.getActionId(waypoint.actions![i].actionType).toString(),
              waypoint.actions![i].actionParam.toString()
            ];
          } else {
            return ["-1", "0"];
          }
        }).expand((x) => x),
        waypoint.altitudeMode == AltitudeMode.agl ? "0" : "1",
        waypoint.speed.toString(),
        waypoint.poi?.latitude.toString() ?? "0",
        waypoint.poi?.longitude.toString() ?? "0",
        waypoint.poi?.altitude.toString() ?? "0",
        waypoint.poi?.altitudeMode == AltitudeMode.agl ? "0" : "1",
        waypoint.photoTimeInterval?.toString() ?? "-1",
        waypoint.photoDistanceInterval?.toString() ?? "-1"
      ];

      csvContent.add(row);
    }

    return const ListToCsvConverter().convert(csvContent);
  }
}
