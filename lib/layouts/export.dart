import 'package:universal_io/io.dart';
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

    var placemarks = _generatePlacemarks(listenables);

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
          fileName: "output",
          allowedExtensions: ["kmz"],
          dialogTitle: "Save Mission");

      if (outputPath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Mission export cancelled")));
        }
        return;
      }
    } else {
      outputPath = "output.kmz";
    }

    // Add code here

    if (!kIsWeb) {
      if (!outputPath.endsWith(".kmz")) {
        outputPath += ".kmz";
      }
      // Save file for non-web platforms
      final file = File(outputPath);
      await file.writeAsBytes(zipBytes);
    } else {
      // Save file for web platform
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
    }
  }

  List<Placemark> _generatePlacemarks(ValueListenables listenables) {
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
                      actionParams:
                          GimbalRotateParams(pitch: -90, payloadPosition: 0)),
                if (listenables.delayAtWaypoint > 0)
                  Action(
                      id: id,
                      actionFunction: ActionFunction.hover,
                      actionParams:
                          HoverParams(hoverTime: listenables.delayAtWaypoint)),
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
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: null,
                  child: Text("Save as Litchi Mission (coming soon)")),
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
