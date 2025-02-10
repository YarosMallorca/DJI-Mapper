import 'dart:math';

import 'package:latlong2/latlong.dart';

class DroneMappingEngine {
  /// Altitude in meters
  final double altitude;

  /// Forward overlap in percentage
  final double forwardOverlap;

  /// Side overlap in percentage
  final double sideOverlap;

  /// Sensor width in mm
  final double sensorWidth;

  /// Sensor height in mm
  final double sensorHeight;

  /// Focal length in mm
  final double focalLength;

  /// Image width in pixels
  final int imageWidth;

  /// Image height in pixels
  final int imageHeight;

  /// Angle of the drone in degrees
  final double angle;

  DroneMappingEngine({
    required this.altitude,
    required this.forwardOverlap,
    required this.sideOverlap,
    required this.sensorWidth,
    required this.sensorHeight,
    required this.focalLength,
    required this.imageWidth,
    required this.imageHeight,
    required this.angle,
  });

  double get gsdX => (altitude * sensorWidth) / (imageWidth * focalLength);
  double get gsdY => (altitude * sensorHeight) / (imageHeight * focalLength);

  double get footprintWidth => gsdX * imageWidth;
  double get footprintHeight => gsdY * imageHeight;

  double get effectiveFootprintWidth => footprintWidth * (1 - sideOverlap);
  double get effectiveFootprintHeight => footprintHeight * (1 - forwardOverlap);

  double get flightLineSpacing => footprintWidth * (1 - sideOverlap);
  double get pathSpacing => footprintHeight * (1 - forwardOverlap);

  // Convert LatLng to local coordinate system (in meters)
  static List<Point> _latLngToMeters(List<LatLng> polygon) {
    var origin = polygon[0];
    double originLat = origin.latitude;
    double originLng = origin.longitude;
    return polygon.map((latLng) {
      double x = (latLng.longitude - originLng) *
          (40075000 * cos((originLat * pi) / 180) / 360);
      double y = (latLng.latitude - originLat) * (40075000 / 360);
      return Point(x, y);
    }).toList();
  }

  // Convert local coordinates (in meters) back to LatLng
  static List<LatLng> _metersToLatLng(List<Point> points, LatLng origin) {
    double originLat = origin.latitude;
    double originLng = origin.longitude;
    return points.map((point) {
      double lat = originLat + (point.y / (40075000 / 360));
      double lng = originLng +
          (point.x / (40075000 * cos((originLat * pi) / 180) / 360));
      return LatLng(lat, lng);
    }).toList();
  }

  // Rotate a point around the origin by a given angle
  static Point _rotatePoint(Point point, double angle) {
    double radians = angle * (pi / 180);
    double cosTheta = cos(radians);
    double sinTheta = sin(radians);
    double x = point.x * cosTheta - point.y * sinTheta;
    double y = point.x * sinTheta + point.y * cosTheta;
    return Point(x, y);
  }

  // Rotate a list of points around the origin by a given angle
  static List<Point> _rotatePolygon(List<Point> polygon, double angle) {
    return polygon.map((point) => _rotatePoint(point, angle)).toList();
  }

  // Check if a point is inside a polygon
  static bool _isPointInPolygon(Point point, List<Point> polygon) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if (((polygon[i].y > point.y) != (polygon[j].y > point.y)) &&
          (point.x <
              (polygon[j].x - polygon[i].x) *
                      (point.y - polygon[i].y) /
                      (polygon[j].y - polygon[i].y) +
                  polygon[i].x)) {
        inside = !inside;
      }
    }
    return inside;
  }

  // Calculate the area of a polygon using the Shoelace formula
  static double calculateArea(List<LatLng> polygon) {
    var localPolygon = _latLngToMeters(polygon);
    double area = 0.0;
    for (int i = 0; i < localPolygon.length - 1; i++) {
      area += localPolygon[i].x * localPolygon[i + 1].y -
          localPolygon[i + 1].x * localPolygon[i].y;
    }
    area += localPolygon.last.x * localPolygon.first.y -
        localPolygon.first.x * localPolygon.last.y;
    return area.abs() / 2.0;
  }

  // Generate waypoints within the polygon in a boustrophedon pattern
  List<LatLng> generateWaypoints(List<LatLng> polygon, bool createCameraPoints, [bool fillGrid = false]) {
    var localPolygon = _latLngToMeters(polygon);
    var rotatedPolygon = _rotatePolygon(localPolygon, angle);
    var origin = polygon[0];

    num minX = rotatedPolygon.map((p) => p.x).reduce(min);
    num maxX = rotatedPolygon.map((p) => p.x).reduce(max);
    num minY = rotatedPolygon.map((p) => p.y).reduce(min);
    num maxY = rotatedPolygon.map((p) => p.y).reduce(max);

    List<Point> waypoints = [];
    bool reverse = false;

    for (num y = minY; y <= maxY; y += pathSpacing) {
      List<Point> line = [];
      if (createCameraPoints) {
        for (num x = minX; x <= maxX; x += flightLineSpacing) {
          Point p = Point(x, y);
          if (_isPointInPolygon(p, rotatedPolygon)) {
            line.add(p);
          }
        }
        if (line.isNotEmpty) {
          Point lastInLine = line.last;
          if ((maxX - lastInLine.x).abs() > 1e-6) {
            Point candidate = Point(maxX, y);
            if (_isPointInPolygon(candidate, rotatedPolygon)) {
              line.add(candidate);
            }
          }
        }
      } else {
        Point? firstPoint;
        Point? lastPoint;
        for (num x = minX; x <= maxX; x += flightLineSpacing) {
          Point p = Point(x, y);
          if (_isPointInPolygon(p, rotatedPolygon)) {
            firstPoint ??= p;
            lastPoint = p;
          }
        }
        if (firstPoint != null) {
          if (lastPoint != null && (maxX - lastPoint.x).abs() > 1e-6) {
            Point candidate = Point(maxX, y);
            if (_isPointInPolygon(candidate, rotatedPolygon)) {
              lastPoint = candidate;
            }
          }
          line.add(firstPoint);
          if (lastPoint != null && lastPoint != firstPoint) {
            line.add(lastPoint);
          }
        }
      }
      if (reverse) {
        line = line.reversed.toList();
      }
      waypoints.addAll(line);
      reverse = !reverse;
    }

    Point lastHorizontalPoint = waypoints.isNotEmpty ? waypoints.last : Point(minX, minY);

    if (fillGrid) {
      List<Point> verticalWaypoints = generateVerticalWaypoints(
        rotatedPolygon,
        createCameraPoints,
        lastHorizontalPoint,
        minX,
        maxX,
        minY,
        maxY,
      );
      waypoints.addAll(verticalWaypoints);
    }

    // Rotate the combined waypoints back to the original orientation.
    var rotatedWaypointsBack = _rotatePolygon(waypoints, -angle);
    return _metersToLatLng(rotatedWaypointsBack, origin);
  }

  /// Generates a vertical boustrophedon pattern to “fill” the polygon.
  List<Point> generateVerticalWaypoints(List<Point> polygon, bool createCameraPoints, Point lastHorizontal, num minX, num maxX, num minY, num maxY) {
    List<Point> verticalWaypoints = [];

    num startX;
    num deltaX;
    if ((lastHorizontal.x - minX).abs() <= (maxX - lastHorizontal.x).abs()) {
      startX = minX;
      deltaX = pathSpacing; // move rightwards from the left edge
    } else {
      startX = maxX;
      deltaX = -pathSpacing; // move leftwards from the right edge
    }

    List<num> verticalYCoords = [];
    for (num y = minY; y <= maxY; y += pathSpacing) {
      verticalYCoords.add(y);
    }

    bool reverse = false;
    bool condition(num x) => deltaX > 0 ? x <= maxX : x >= minX;

    for (num x = startX; condition(x); x += deltaX) {
      List<Point> column = [];
      for (num y in verticalYCoords) {
        Point p = Point(x, y);
        if (_isPointInPolygon(p, polygon)) {
          column.add(p);
        }
      }
      if (column.isEmpty) continue;

      if (!createCameraPoints) {
        Point lowerEndpoint = column.first;
        Point upperEndpoint = column.last;
        if (x == startX) {
          double distToLower = (lastHorizontal.y - lowerEndpoint.y).abs().toDouble();
          double distToUpper = (lastHorizontal.y - upperEndpoint.y).abs().toDouble();
          if (distToLower <= distToUpper) {
            column = [lowerEndpoint, upperEndpoint];
          } else {
            column = [upperEndpoint, lowerEndpoint];
          }
        } else {
          column = [lowerEndpoint, upperEndpoint];
        }
      } else {
        if (x == startX && column.length >= 2) {
          double distToLower = (lastHorizontal.y - column.first.y).abs().toDouble();
          double distToUpper = (lastHorizontal.y - column.last.y).abs().toDouble();
          if (distToUpper < distToLower) {
            column = column.reversed.toList();
          }
        }
      }

      if (reverse) {
        column = column.reversed.toList();
      }
      verticalWaypoints.addAll(column);
      reverse = !reverse;
    }

    return verticalWaypoints;
  }

  static double calculateTotalDistance(List<LatLng> waypoints) {
    if (waypoints.length < 2) return 0.0;
    double totalDistance = 0.0;

    for (int i = 0; i < waypoints.length - 1; i++) {
      totalDistance += _haversineDistance(waypoints[i], waypoints[i + 1]);
    }

    return totalDistance;
  }

  static String calculateRecommendedShutterSpeed({
    required int altitude, // in meters
    required double sensorWidth, // in meters
    required double focalLength, // in meters
    required int imageWidth, // in pixels
    required double droneSpeed, // in meters per second (m/s)
  }) {
    // Calculate Ground Sampling Distance (GSD) in meters/pixel
    double gsd = (altitude * sensorWidth) / (imageWidth * focalLength);

    // Calculate recommended shutter speed to avoid motion blur (in seconds)
    double shutterSpeed = gsd / droneSpeed;

    // Find the closest standard speed
    double closest = _standardSpeeds.first;
    for (double speed in _standardSpeeds) {
      if ((shutterSpeed - speed).abs() < (shutterSpeed - closest).abs()) {
        closest = speed;
      }
    }

    return '1/${(1 / closest).toInt()}';
  }

  static double _haversineDistance(LatLng p1, LatLng p2) {
    const R = 6371e3; // Earth radius in meters
    final phi1 = p1.latitudeInRad;
    final phi2 = p2.latitudeInRad;
    final deltaPhi = (p2.latitude - p1.latitude).toRadians();
    final deltaLambda = (p2.longitude - p1.longitude).toRadians();

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in meters
  }

  static final List<double> _standardSpeeds = [
    1 / 16000,
    1 / 8000,
    1 / 6400,
    1 / 5000,
    1 / 4000,
    1 / 3200,
    1 / 2500,
    1 / 2000,
    1 / 1600,
    1 / 1250,
    1 / 1000,
    1 / 800,
    1 / 640,
    1 / 500,
    1 / 400,
    1 / 320,
    1 / 240,
    1 / 200,
    1 / 160,
    1 / 120,
    1 / 100,
    1 / 80,
    1 / 60,
    1 / 50,
    1 / 40,
    1 / 30,
    1 / 25,
    1 / 20,
    1 / 15,
    1 / 12.5,
    1 / 10,
    1 / 8,
    1 / 6.25,
    1 / 5,
    1 / 4,
    1 / 3,
    1 / 2,
  ];
}

extension on double {
  double toRadians() => this * pi / 180;
}
