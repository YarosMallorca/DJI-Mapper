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

  /// Ground offset in meters (e.g., height of target surface above ground)
  final double groundOffset;

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
    required this.groundOffset,
  });

  double get effectiveAltitude => altitude - groundOffset;

  double get gsdX => (effectiveAltitude * sensorWidth) / (imageWidth * focalLength);
  double get gsdY => (effectiveAltitude * sensorHeight) / (imageHeight * focalLength);

  double get footprintWidth => gsdX * imageWidth;
  double get footprintHeight => gsdY * imageHeight;

  double get effectiveFootprintWidth => footprintWidth * (1 - sideOverlap);
  double get effectiveFootprintHeight => footprintHeight * (1 - forwardOverlap);

  double get flightLineSpacing => footprintWidth * (1 - sideOverlap);
  double get pathSpacing => footprintHeight * (1 - forwardOverlap);

  // Spacing for horizontal lines
  double get horizontalLineSpacing => footprintHeight * (1 - sideOverlap);      // Y spacing (cross-track)
  double get horizontalWaypointSpacing => footprintWidth * (1 - forwardOverlap); // X spacing (along-track)

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

  static Point _latLngToPoint(LatLng latLng, LatLng origin) {
    double x = (latLng.longitude - origin.longitude) * (40075000 * cos((origin.latitude * pi) / 180) / 360);
    double y = (latLng.latitude - origin.latitude) * (40075000 / 360);
    return Point(x, y);
  }

  static LatLng _pointToLatLng(Point point, LatLng origin) {
    double lat = origin.latitude + (point.y / (40075000 / 360));
    double lng = origin.longitude + (point.x / (40075000 * cos((origin.latitude * pi) / 180) / 360));
    return LatLng(lat, lng);
  }

  static double _distance(Point a, Point b) {
    return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
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
  List<LatLng> generateWaypoints(List<LatLng> polygon, bool createCameraPoints, [bool fillGrid = false, LatLng? homePoint = null]) {
    var localPolygon = _latLngToMeters(polygon);
    var rotatedPolygon = _rotatePolygon(localPolygon, angle);
    var origin = polygon[0];

    num minX = rotatedPolygon.map((p) => p.x).reduce(min);
    num maxX = rotatedPolygon.map((p) => p.x).reduce(max);
    num minY = rotatedPolygon.map((p) => p.y).reduce(min);
    num maxY = rotatedPolygon.map((p) => p.y).reduce(max);

    if (homePoint == null) {
      List<Point> waypoints = [];
      bool reverse = false;

      for (num y = minY; y <= maxY; y += horizontalLineSpacing) {
        List<Point> line = [];
        if (createCameraPoints) {
          for (num x = minX; x <= maxX; x += horizontalWaypointSpacing) {
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
          for (num x = minX; x <= maxX; x += horizontalWaypointSpacing) {
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

      if (fillGrid) {
        var lastHorizontal = waypoints.last;
        var verticalWaypoints = _generateVerticalWaypoints(rotatedPolygon, createCameraPoints, lastHorizontal, minX, maxX, minY, maxY);
        waypoints.addAll(verticalWaypoints);
      }

      var rotatedWaypointsBack = _rotatePolygon(waypoints, -angle);
      return _metersToLatLng(rotatedWaypointsBack, origin);
    } else {
      Point homeP = _latLngToPoint(homePoint, origin);
      List<Point> selected;

      if (!fillGrid) {
        var horiz = _generateHorizontalWaypoints(rotatedPolygon, createCameraPoints, homeP, minX, maxX, minY, maxY);
        if(horiz.isEmpty) {
          return [];
        }
        var horizRev = horiz.reversed.toList();
        double distHoriz = _distance(horiz.last, homeP);
        double distHorizRev = _distance(horizRev.last, homeP);
        selected = distHoriz < distHorizRev ? horiz : horizRev;
      } else {
        // Horizontal first
        var horiz = _generateHorizontalWaypoints(rotatedPolygon, createCameraPoints, homeP, minX, maxX, minY, maxY);
        var vert = _generateVerticalWaypoints(rotatedPolygon, createCameraPoints, horiz.last, minX, maxX, minY, maxY);
        var pathHF = [...horiz, ...vert];
        var pathHFRev = pathHF.reversed.toList();

        // Vertical first
        var vertF = _generateVerticalWaypoints(rotatedPolygon, createCameraPoints, homeP, minX, maxX, minY, maxY);
        var horizA = _generateHorizontalWaypoints(rotatedPolygon, createCameraPoints, vertF.last, minX, maxX, minY, maxY);
        var pathVF = [...vertF, ...horizA];
        var pathVFRev = pathVF.reversed.toList();

        var paths = [pathHF, pathHFRev, pathVF, pathVFRev];
        var best = paths[0];
        var bestDist = _distance(best.last, homeP);
        for (var p in paths.skip(1)) {
          var d = _distance(p.last, homeP);
          if (d < bestDist) {
            bestDist = d;
            best = p;
          }
        }
        selected = best;
      }

      var rotatedWaypointsBack = _rotatePolygon(selected, -angle);
      return _metersToLatLng(rotatedWaypointsBack, origin);
    }
  }

  List<Point> _generateVerticalWaypoints(List<Point> polygon, bool createCameraPoints,Point lastHorizontal, num minHorizontalX, num maxHorizontalX, num minHorizontalY, num maxHorizontalY) {
    var verticalLineSpacing = footprintWidth * (1 - sideOverlap);  // Fixed bug: Use width for side overlap in vertical lines
    var verticalWaypointSpacing = footprintHeight * (1 - forwardOverlap);
    num offset = verticalWaypointSpacing * 0.1;

    List<num> verticalYCoords = [];
    num adjustedMinY = minHorizontalY - verticalWaypointSpacing / 2 - offset;
    for (num y = adjustedMinY; y <= maxHorizontalY + verticalWaypointSpacing / 2; y += verticalWaypointSpacing) {
      verticalYCoords.add(y);
    }

    num xLeft = minHorizontalX + verticalLineSpacing / 2;
    List<num> yLeft = verticalYCoords.where((y) => _isPointInPolygon(Point(xLeft, y), polygon)).toList();
    num minDistLeft = double.infinity;
    num distBottomLeft = double.infinity;
    num distTopLeft = double.infinity;
    if (yLeft.isNotEmpty) {
      num yBottomLeft = yLeft.first;
      num yTopLeft = yLeft.last;
      distBottomLeft = sqrt(pow(xLeft - lastHorizontal.x, 2) + pow(yBottomLeft - lastHorizontal.y, 2));
      distTopLeft = sqrt(pow(xLeft - lastHorizontal.x, 2) + pow(yTopLeft - lastHorizontal.y, 2));
      minDistLeft = min(distBottomLeft, distTopLeft);
    }

    num xRight = maxHorizontalX - verticalLineSpacing / 2;
    List<num> yRight = verticalYCoords.where((y) => _isPointInPolygon(Point(xRight, y), polygon)).toList();
    num minDistRight = double.infinity;
    num distBottomRight = double.infinity;
    num distTopRight = double.infinity;
    if (yRight.isNotEmpty) {
      num yBottomRight = yRight.first;
      num yTopRight = yRight.last;
      distBottomRight = sqrt(pow(xRight - lastHorizontal.x, 2) + pow(yBottomRight - lastHorizontal.y, 2));
      distTopRight = sqrt(pow(xRight - lastHorizontal.x, 2) + pow(yTopRight - lastHorizontal.y, 2));
      minDistRight = min(distBottomRight, distTopRight);
    }

    num startX;
    num deltaX;
    bool reverse;
    if (minDistLeft < minDistRight) {
      startX = xLeft;
      deltaX = verticalLineSpacing;
      reverse = distTopLeft < distBottomLeft;
    } else {
      startX = xRight;
      deltaX = -verticalLineSpacing;
      reverse = distTopRight < distBottomRight;
    }

    List<Point> verticalWaypoints = [];
    bool condition(num x) => deltaX > 0 ? x <= maxHorizontalX + verticalLineSpacing / 2 : x >= minHorizontalX - verticalLineSpacing / 2;
    for (num x = startX; condition(x); x += deltaX) {
      List<Point> column = [];
      for (num y in verticalYCoords) {
        Point p = Point(x, y);
        if (_isPointInPolygon(p, polygon)) {
          column.add(p);
        }
      }
      if (column.isEmpty) continue;

      if (reverse) column = column.reversed.toList();

      if (createCameraPoints) {
        verticalWaypoints.addAll(column);
      } else {
        verticalWaypoints.add(column.first);
        if (column.first != column.last) {
          verticalWaypoints.add(column.last);
        }
      }
      reverse = !reverse;
    }

    return verticalWaypoints;
  }

  List<Point> _generateHorizontalWaypoints(List<Point> polygon, bool createCameraPoints, Point previous, num minX, num maxX, num minY, num maxY) {
    num lineSpacing = footprintHeight * (1 - sideOverlap);
    num waypointSpacing = footprintWidth * (1 - forwardOverlap);
    num offset = waypointSpacing * 0.1;

    List<num> alongCoords = [];
    num adjustedMinAlong = minX - waypointSpacing / 2 - offset;
    for (num x = adjustedMinAlong; x <= maxX + waypointSpacing / 2; x += waypointSpacing) {
      alongCoords.add(x);
    }

    num yBottom = minY + lineSpacing / 2;
    List<num> xBottom = alongCoords.where((x) => _isPointInPolygon(Point(x, yBottom), polygon)).toList();
    num minDistBottom = double.infinity;
    num distLeftBottom = double.infinity;
    num distRightBottom = double.infinity;
    if (xBottom.isNotEmpty) {
      num xLeftBottom = xBottom.first;
      num xRightBottom = xBottom.last;
      distLeftBottom = sqrt(pow(previous.x - xLeftBottom, 2) + pow(previous.y - yBottom, 2));
      distRightBottom = sqrt(pow(previous.x - xRightBottom, 2) + pow(previous.y - yBottom, 2));
      minDistBottom = min(distLeftBottom, distRightBottom);
    }

    num yTop = maxY - lineSpacing / 2;
    List<num> xTop = alongCoords.where((x) => _isPointInPolygon(Point(x, yTop), polygon)).toList();
    num minDistTop = double.infinity;
    num distLeftTop = double.infinity;
    num distRightTop = double.infinity;
    if (xTop.isNotEmpty) {
      num xLeftTop = xTop.first;
      num xRightTop = xTop.last;
      distLeftTop = sqrt(pow(previous.x - xLeftTop, 2) + pow(previous.y - yTop, 2));
      distRightTop = sqrt(pow(previous.x - xRightTop, 2) + pow(previous.y - yTop, 2));
      minDistTop = min(distLeftTop, distRightTop);
    }

    num startY;
    num deltaY;
    bool reverse;
    if (minDistBottom < minDistTop) {
      startY = yBottom;
      deltaY = lineSpacing;
      reverse = distRightBottom < distLeftBottom;
    } else {
      startY = yTop;
      deltaY = -lineSpacing;
      reverse = distRightTop < distLeftTop;
    }

    List<Point> horizontalWaypoints = [];
    bool condition(num y) => deltaY > 0 ? y <= maxY + lineSpacing / 2 : y >= minY - lineSpacing / 2;
    for (num y = startY; condition(y); y += deltaY) {
      List<Point> line = [];
      for (num x in alongCoords) {
        Point p = Point(x, y);
        if (_isPointInPolygon(p, polygon)) {
          line.add(p);
        }
      }
      if (line.isEmpty) continue;

      if (reverse) line = line.reversed.toList();

      if (createCameraPoints) {
        horizontalWaypoints.addAll(line);
      } else {
        horizontalWaypoints.add(line.first);
        if (line.first != line.last) {
          horizontalWaypoints.add(line.last);
        }
      }
      reverse = !reverse;
    }

    return horizontalWaypoints;
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
