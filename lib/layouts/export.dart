import 'package:dji_mapper/core/drone_mapper_format.dart';
import 'package:geoxml/geoxml.dart';
import 'package:latlong2/latlong.dart';
import 'package:universal_io/io.dart';
import 'package:dji_mapper/components/popups/dji_load_alert.dart';
import 'package:dji_mapper/components/popups/litchi_load_alert.dart';
import 'package:dji_mapper/main.dart';
import 'package:litchi_waypoint_engine/engine.dart' as litchi;
import 'package:universal_html/html.dart' as html;
import 'package:archive/archive.dart';
import 'package:dji_waypoint_engine/engine.dart';
import 'package:dji_mapper/shared/value_listeneables.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:provider/provider.dart';

class ExportBar extends StatefulWidget {
  const ExportBar({super.key});

  @override
  State<ExportBar> createState() => ExportBarState();
}

class ExportBarState extends State<ExportBar> {
  Future<void> _exportForDJIFly(ValueListenables listenables) async {
    var missionConfig = MissionConfig(

        /// Always fly safely
        /// This is the default for DJI Fly anyway
        flyToWaylineMode: FlyToWaylineMode.safely,

        /// This will be added later
        finishAction: listenables.onFinished,

        /// To comply with EU regulations
        /// Always execute lost action on RC signal lost
        /// do not continue the mission
        exitOnRCLost: ExitOnRCLost.executeLostAction,

        /// For now it's deafult to go back home on RC signal lost
        rcLostAction: listenables.rcLostAction,

        /// The speed to the first waypoint
        /// For now this is the general speed of the mission
        globalTransitionalSpeed: listenables.speed,

        /// Drone information for DJI Fly is default at 68
        /// Unsure what other values there can be
        /// Can't find official documentation
        droneInfo: DroneInfo(droneEnumValue: 68));

    var template = TemplateKml(
        document: KmlDocumentElement(

            /// The author is always `fly` for now
            author: "fly",
            creationTime: DateTime.now(),
            modificationTime: DateTime.now(),

            /// The template and waylines take the same mission config
            /// Not sure why duplication is necessary
            missionConfig: missionConfig));

    var placemarks = _generateDjiPlacemarks(listenables);

    if (placemarks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No waypoints to export. Please add waypoints first")));
      return;
    }

    var waylines = WaylinesWpml(
        document: WpmlDocumentElement(
            missionConfig: missionConfig,
            folderElement: FolderElement(
                templateId: 0, // Only one mission, so this is always 0
                waylineId: 0, // Only one wayline, so this is always 0
                speed: listenables.speed,
                placemarks: placemarks)));

    var templateString = template.toXmlString(pretty: true);
    var waylinesString = waylines.toXmlString(pretty: true);

    var encoder = ZipEncoder();
    var archive = Archive();

    archive.addFile(ArchiveFile('template.kml', templateString.length,
        Uint8List.fromList(templateString.codeUnits)));

    archive.addFile(ArchiveFile('waylines.wpml', waylinesString.length,
        Uint8List.fromList(waylinesString.codeUnits)));

    var zipData = encoder.encode(archive);
    var zipBytes = Uint8List.fromList(zipData!);

    String? outputPath;

    if (!kIsWeb) {
      outputPath = await FilePicker.platform.saveFile(
          type: FileType.custom,
          fileName: "output.kmz",
          allowedExtensions: ["kmz"],
          bytes: zipBytes,
          dialogTitle: "Save Mission");

      if (outputPath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Mission export cancelled")));
        }
        return;
      }

      // File Saver does not save the file on Desktop platforms
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        if (!outputPath.endsWith(".kmz")) {
          outputPath += ".kmz";
        }
        // Save file for non-web platforms
        final file = File(outputPath);
        await file.writeAsBytes(zipBytes);
      }
    } else {
      // Save file for web platform
      outputPath = "output.kmz";
      final blob = html.Blob([zipBytes], 'application/octet-stream');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "output.kmz")
        ..click();
      html.Url.revokeObjectUrl(url);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mission exported successfully")));

      if (!(prefs.getBool("djiWarningDoNotShow") ?? false)) {
        showDialog(
            context: context, builder: (context) => const DjiLoadAlert());
      }
    }
  }

  Future<void> _exportForLithi(ValueListenables listenables) async {
    final waypoints = _generateLitchiWaypoints(listenables);

    if (waypoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No waypoints to export. Please add waypoints first")));
      return;
    }

    String csvContent = litchi.LitchiCsv.generateCsv(waypoints);

    String? outputPath;

    if (!kIsWeb) {
      outputPath = await FilePicker.platform.saveFile(
          type: FileType.custom,
          fileName: "litchi_mission.csv",
          allowedExtensions: ["csv"],
          bytes: Uint8List.fromList(csvContent.codeUnits),
          dialogTitle: "Save Mission");

      if (outputPath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Mission export cancelled")));
        }
        return;
      }

      // File Saver does not save the file on Desktop platforms
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        if (!outputPath.endsWith(".csv")) {
          outputPath += ".csv";
        }
        // Save file for non-web platforms
        final file = File(outputPath);
        await file.writeAsString(csvContent);
      }
    } else {
      // Save file for web platform
      outputPath = "output.csv";
      final blob = html.Blob([csvContent], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "litchi_mission.csv")
        ..click();
      html.Url.revokeObjectUrl(url);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mission exported successfully")));
      if (!(prefs.getBool("litchiWarningDoNotShow") ?? false)) {
        showDialog(
            context: context, builder: (context) => const LitchiLoadAlert());
      }
    }
  }

  List<litchi.Waypoint> _generateLitchiWaypoints(ValueListenables listenables) {
    var waypoints = <litchi.Waypoint>[];

    for (var photoLocation in listenables.photoLocations) {
      waypoints.add(litchi.Waypoint(
          latitude: photoLocation.latitude,
          longitude: photoLocation.longitude,
          altitude: listenables.altitude,
          speed: listenables.speed.toInt(),
          gimbalPitch: listenables.cameraAngle,
          gimbalMode: litchi.GimbalMode.interpolate,
          actions: [
            if (listenables.delayAtWaypoint > 0)
              litchi.Action(
                  actionType: litchi.ActionType.stayFor,

                  // Litchi uses milliseconds for delay time
                  actionParam: listenables.delayAtWaypoint.toDouble() * 1000),

            if(listenables.createCameraPoints)
              litchi.Action(actionType: litchi.ActionType.takePhoto)
          ]));
    }

    return waypoints;
  }

  List<Placemark> _generateDjiPlacemarks(ValueListenables listenables) {
    var placemarks = <Placemark>[];

    for (var photoLocation in listenables.photoLocations) {
      int id = listenables.photoLocations.indexOf(photoLocation);
      placemarks.add(Placemark(
          point: WaypointPoint(
              longitude: photoLocation.longitude,
              latitude: photoLocation.latitude),
          index: id,
          height: listenables.altitude,
          speed: listenables.speed,
          headingParam: HeadingParam(
              headingMode: HeadingMode.followWayline,
              headingPathMode: HeadingPathMode.followBadArc),
          turnParam: TurnParam(
              waypointTurnMode:
                  WaypointTurnMode.toPointAndStopWithDiscontinuityCurvature,
              turnDampingDistance: 0),
          useStraightLine: true,
          actionGroup: ActionGroup(
              id: 0,
              startIndex: id,
              endIndex: id,
              actions: [
                if (id == 0)
                  Action(
                      id: id,
                      actionFunction: ActionFunction.gimbalEvenlyRotate,
                      actionParams: GimbalRotateParams(
                          pitch: listenables.cameraAngle.toDouble(),
                          payloadPosition: 0)),
                if (listenables.delayAtWaypoint > 0)
                  Action(
                      id: id,
                      actionFunction: ActionFunction.hover,
                      actionParams:
                          HoverParams(hoverTime: listenables.delayAtWaypoint)),
                if(listenables.createCameraPoints)
                  Action(
                      id: id,
                      actionFunction: ActionFunction.takePhoto,
                      actionParams: CameraControlParams(payloadPosition: 0)),
              ],
              mode: ActionMode.sequence,
              trigger: ActionTriggerType.reachPoint)));
    }

    return placemarks;
  }

  Future<void> _importFromKml(ValueListenables listenables) async {
    var file = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["kml"],
        dialogTitle: "Load Area");

    if (file == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("No file selected. Import cancelled")));
      }
      return;
    }

    late DroneMapperXml kml;

    if (kIsWeb) {
      kml = await DroneMapperXml.fromKmlString(
          String.fromCharCodes(file.files.first.bytes!));
    } else {
      kml = await DroneMapperXml.fromKmlString(
          await File(file.files.single.path!).readAsString());
    }

    if (kml.polygons.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No polygons found in KML. Import cancelled")));
      return;
    } else if (kml.polygons.length > 1) {
      if (mounted) {
        int selectedPolygon = 0;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Select Polygon"),
              content: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          "Multiple polygons found in the KML file, please select one"),
                      const Divider(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: 400,
                        child: ListView.separated(
                          itemCount: kml.polygons.length,
                          itemBuilder: (context, index) => CheckboxListTile(
                            value: selectedPolygon == index,
                            onChanged: (value) {
                              setState(() {
                                selectedPolygon = index;
                              });
                            },
                            title: Text(
                                kml.polygons[index].name ?? "Polygon $index"),
                          ),
                          separatorBuilder: (context, index) => const Divider(),
                          shrinkWrap: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel")),
                FilledButton(
                    onPressed: () {
                      // Ensure a polygon is selected before proceeding
                      if (selectedPolygon >= 0 &&
                          selectedPolygon < kml.polygons.length) {
                        _loadPolygon(
                          kml.polygons[selectedPolygon].outerBoundaryIs.rtepts
                              .map((e) => LatLng(e.lat!, e.lon!))
                              .toList(),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Load")),
              ],
            );
          },
        );
      }
      return;
    } else {
      _loadPolygon(kml.polygons.first.outerBoundaryIs.rtepts
          .map((e) => LatLng(e.lat!, e.lon!))
          .toList());
      return;
    }
  }

  Future<void> _loadPolygon(List<LatLng> polygon) async {
    Provider.of<ValueListenables>(context, listen: false).polygon = polygon;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Area imported successfully")));
    }
  }

  Future<void> _exportAreaToKml(ValueListenables listenables) async {
    if (listenables.polygon.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No polygon to export. Please add waypoints first")));
      return;
    }
    var kml = DroneMapperXml();
    kml.polygons = [
      Polygon(
        name: "Mapping Area",
        outerBoundaryIs: Rte(
            rtepts: listenables.polygon
                .map((element) =>
                    Wpt(lat: element.latitude, lon: element.longitude))
                .toList()),
      )
    ];

    var kmlString = kml.toKmlString(pretty: true);

    String? outputPath;

    if (!kIsWeb) {
      outputPath = await FilePicker.platform.saveFile(
          type: FileType.custom,
          fileName: "area.kml",
          allowedExtensions: ["kml"],
          bytes: Uint8List.fromList(kmlString.codeUnits),
          dialogTitle: "Save Area");

      if (outputPath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Area export cancelled")));
        }
        return;
      }

      // File Saver does not save the file on Desktop platforms
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        if (!outputPath.endsWith(".kml")) {
          outputPath += ".kml";
        }
        // Save file for non-web platforms
        final file = File(outputPath);
        await file.writeAsBytes(Uint8List.fromList(kmlString.codeUnits));
      }
    } else {
      // Save file for web platform
      outputPath = "area.kml";
      final blob = html.Blob([Uint8List.fromList(kmlString.codeUnits)],
          'application/octet-stream');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "area.kml")
        ..click();
      html.Url.revokeObjectUrl(url);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Area exported successfully")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<ValueListenables>(builder: (context, listenables, child) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Export your Survey Mission",
                  style: TextStyle(fontSize: 20)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () => _exportForDJIFly(listenables),
                  child: const Text("Save as DJI Fly Waypoint Mission")),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () => _exportForLithi(listenables),
                  child: const Text("Save as Litchi Mission")),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Import/Export Mapping Area",
                  style: TextStyle(fontSize: 20)),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Tooltip(
                    message: "This will override the current mapping area",
                    child: ElevatedButton(
                        onPressed: () => _importFromKml(listenables),
                        child: const Text("Import from KML")),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                      onPressed: () => _exportAreaToKml(listenables),
                      child: const Text("Export to KML")),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 3,
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withOpacity(0.5)),
                    color: Theme.of(context)
                        .colorScheme
                        .errorContainer
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Warning",
                        style: TextStyle(
                            fontSize: 20,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "I am not responsible for any damage or loss of equipment or data. Use at your own risk.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "If you notice any issues during the mission, please stop the mission immediately.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
