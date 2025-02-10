import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dji_mapper/components/app_bar.dart';
import 'package:dji_mapper/core/drone_mapping_engine.dart';
import 'package:dji_mapper/github/update_checker.dart';
import 'package:dji_mapper/layouts/aircraft.dart';
import 'package:dji_mapper/layouts/camera.dart';
import 'package:dji_mapper/layouts/export.dart';
import 'package:dji_mapper/layouts/info.dart';
import 'package:dji_mapper/main.dart';
import 'package:dji_mapper/presets/preset_manager.dart';
import 'package:dji_mapper/shared/value_listeneables.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/aircraft_settings.dart';

enum MapLayer { streets, satellite }

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with TickerProviderStateMixin {
  final MapController mapController = MapController();
  late final TabController _tabController;

  late MapLayer _selectedMapLayer;

  final List<Marker> _photoMarkers = [];

  final _debounce = const Duration(milliseconds: 800);
  Timer? _debounceTimer;
  List<MapSearchLocation> _searchLocations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _getLocationAndMoveMap();

    _selectedMapLayer =
        prefs.getInt("mapLayer") == 1 ? MapLayer.satellite : MapLayer.streets;

    final listenables = Provider.of<ValueListenables>(context, listen: false);

    // Preload aircraft settings
    final aircraftSettings = AircraftSettings.getAircraftSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      listenables.altitude = aircraftSettings.altitude;
      listenables.speed = aircraftSettings.speed;
      listenables.forwardOverlap = aircraftSettings.forwardOverlap;
      listenables.sideOverlap = aircraftSettings.sideOverlap;
      listenables.rotation = aircraftSettings.rotation;
      listenables.delayAtWaypoint = aircraftSettings.delay;
      listenables.cameraAngle = aircraftSettings.cameraAngle;
      listenables.onFinished = aircraftSettings.finishAction;
      listenables.rcLostAction = aircraftSettings.rcLostAction;
    });

    var cameraPresets = PresetManager.getPresets();

    // Load the latest camera preset
    var latestPresetName = prefs.getString("latestPreset");
    if (latestPresetName == null) {
      latestPresetName = cameraPresets[0].name;
      prefs.setString("latestPreset", latestPresetName);
    }

    // Select the latest camera preset
    listenables.selectedCameraPreset = cameraPresets.firstWhere(
        (element) => element.name == latestPresetName,
        orElse: () => cameraPresets[0]);

    // Load camera settings into the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      listenables.sensorWidth = listenables.selectedCameraPreset!.sensorWidth;
      listenables.sensorHeight = listenables.selectedCameraPreset!.sensorHeight;
      listenables.focalLength = listenables.selectedCameraPreset!.focalLength;
      listenables.imageWidth = listenables.selectedCameraPreset!.imageWidth;
      listenables.imageHeight = listenables.selectedCameraPreset!.imageHeight;
    });

    // Check for updates
    if (!kIsWeb) {
      UpdateChecker.checkForUpdate().then((latestVersion) => {
            if (latestVersion != null && mounted)
              {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('Update available'),
                          content: Text('Version $latestVersion is available. '
                              'Do you want to download it?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Later')),
                            TextButton(
                                onPressed: () {
                                  prefs.setString(
                                      "ignoreVersion", latestVersion);
                                  Navigator.pop(context);
                                },
                                child: const Text("Ignore this version")),
                            ElevatedButton(
                                child: const Text('Download'),
                                onPressed: () {
                                  launchUrl(Uri.https("github.com",
                                      "YarosMallorca/DJI-Mapper/releases/latest"));
                                  Navigator.pop(context);
                                })
                          ],
                        ))
              }
          });
    }
  }

  Future<void> _search(String query) async {
    var response = await Dio().get(
      "https://nominatim.openstreetmap.org/search",
      queryParameters: {
        "q": query,
        "format": "jsonv2",
      },
    );

    List<MapSearchLocation> locations = [];
    for (var location in response.data) {
      locations.add(MapSearchLocation(
        name: location["display_name"],
        type: location["type"],
        location: LatLng(
            double.parse(location["lat"]), double.parse(location["lon"])),
      ));
    }

    setState(() {
      _searchLocations = locations;
    });
  }

  void _onSearchChanged(
      String query, Function(List<MapSearchLocation>) callback) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(_debounce, () async {
      await _search(query);

      callback(_searchLocations);
    });
  }

  void _getLocationAndMoveMap() async {
    if (await Geolocator.isLocationServiceEnabled() == false) return;
    if (await Geolocator.checkPermission() == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    final location = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low));
    mapController.move(LatLng(location.latitude, location.longitude), 14);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _buildMarkers(ValueListenables listenables) {
    var droneMapping = DroneMappingEngine(
      altitude: listenables.altitude.toDouble(),
      forwardOverlap: listenables.forwardOverlap / 100,
      sideOverlap: listenables.sideOverlap / 100,
      sensorWidth: listenables.sensorWidth,
      sensorHeight: listenables.sensorHeight,
      focalLength: listenables.focalLength,
      imageWidth: listenables.imageWidth,
      imageHeight: listenables.imageHeight,
      angle: listenables.rotation.toDouble(),
    );

    var waypoints = droneMapping.generateWaypoints(listenables.polygon,
        listenables.createCameraPoints, listenables.fillGrid);
    listenables.photoLocations = waypoints;
    if (waypoints.isEmpty) return;
    _photoMarkers.clear();
    for (var photoLocation in waypoints) {
      _photoMarkers.add(Marker(
          point: photoLocation,
          height: 25,
          alignment: Alignment.center,
          rotate: false,
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(179),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (listenables.createCameraPoints)
                  Icon(Icons.photo_camera,
                      size: 25,
                      color: Theme.of(context).colorScheme.onPrimaryContainer)
                else
                  Icon(Icons.place_sharp,
                      size: 25,
                      color: Theme.of(context).colorScheme.onPrimaryContainer)
              ],
            ),
          )));
    }
    listenables.flightLine = Polyline(
        points: waypoints,
        strokeWidth: 3,
        color: Theme.of(context).colorScheme.tertiary);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ValueListenables>(
      builder: (context, listenables, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (listenables.polygon.length > 2 && listenables.altitude >= 5) {
            _buildMarkers(listenables);
          } else {
            listenables.photoLocations.clear();
            _photoMarkers.clear();
            listenables.flightLine = null;
          }
        });

        var children = [
          Flexible(
            flex: 2,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                onTap: (tapPosition, point) => {
                  setState(() {
                    listenables.polygon.add(point);
                  }),
                },
              ),
              children: [
                TileLayer(
                    tileProvider: CancellableNetworkTileProvider(),
                    tileBuilder:
                        Theme.of(context).brightness == Brightness.dark &&
                                _selectedMapLayer == MapLayer.streets
                            ? (context, tileWidget, tile) =>
                                darkModeTileBuilder(context, tileWidget, tile)
                            : null,
                    urlTemplate: _selectedMapLayer == MapLayer.streets
                        ? 'https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}'
                        : 'https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
                    userAgentPackageName: 'com.yarosfpv.dji_mapper',
                    subdomains: const ['mt0', 'mt1', 'mt2', 'mt3']),
                PolygonLayer(polygons: [
                  if (listenables.polygon.length > 1)
                    Polygon(
                        points: listenables.polygon,
                        color:
                            Theme.of(context).colorScheme.primary.withAlpha(77),
                        borderColor: Theme.of(context).colorScheme.primary,
                        borderStrokeWidth: 3),
                ]),
                PolylineLayer(polylines: [
                  listenables.flightLine ?? Polyline(points: [])
                ]),
                if (listenables.showPoints) MarkerLayer(markers: _photoMarkers),
                DragMarkers(markers: [
                  for (var point in listenables.polygon)
                    DragMarker(
                      size: const Size(30, 30),
                      point: point,
                      alignment: Alignment.topCenter,
                      builder: (_, coords, b) => GestureDetector(
                          onSecondaryTap: () => setState(() {
                                if (listenables.polygon.contains(point)) {
                                  listenables.polygon.remove(point);
                                }
                              }),
                          child: const Icon(Icons.place, size: 30)),
                      onDragUpdate: (details, latLng) => {
                        if (listenables.polygon.contains(point))
                          {
                            listenables.polygon[
                                listenables.polygon.indexOf(point)] = latLng
                          }
                      },
                    ),
                ]),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Autocomplete<MapSearchLocation>(
                        optionsBuilder: (textEditingValue) {
                          return Future.delayed(_debounce, () async {
                            _onSearchChanged(textEditingValue.text,
                                (locations) => locations);
                            return _searchLocations;
                          });
                        },
                        onSelected: (option) =>
                            mapController.move(option.location, 12),
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                  elevation: 4.0,
                                  child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                          maxHeight: 200, maxWidth: 600),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final option =
                                              options.elementAt(index);
                                          return InkWell(
                                            onTap: () {
                                              onSelected(option);
                                            },
                                            child: Builder(builder:
                                                (BuildContext context) {
                                              final bool highlight =
                                                  AutocompleteHighlightedOption
                                                          .of(context) ==
                                                      index;
                                              if (highlight) {
                                                SchedulerBinding.instance
                                                    .addPostFrameCallback(
                                                        (Duration timeStamp) {
                                                  Scrollable.ensureVisible(
                                                      context,
                                                      alignment: 0.5);
                                                });
                                              }
                                              return Container(
                                                color: highlight
                                                    ? Theme.of(context)
                                                        .focusColor
                                                    : null,
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      option.name,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          );
                                        },
                                      ))));
                        },
                        displayStringForOption: (option) => option.name,
                        fieldViewBuilder: (context, textEditingController,
                                focusNode, onFieldSubmitted) =>
                            TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onFieldSubmitted: (value) async {
                            await _search(textEditingController.text);
                            mapController.move(
                                _searchLocations.first.location, 12);
                          },
                          decoration: InputDecoration(
                              hintText: 'Search location',
                              border: const OutlineInputBorder(),
                              filled: true,
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => textEditingController.clear(),
                              ),
                              fillColor: Theme.of(context).colorScheme.surface),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Material(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => setState(() {
                                  _selectedMapLayer =
                                      _selectedMapLayer == MapLayer.streets
                                          ? MapLayer.satellite
                                          : MapLayer.streets;
                                  prefs.setInt(
                                      "mapLayer",
                                      _selectedMapLayer == MapLayer.streets
                                          ? 0
                                          : 1);
                                }),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.layers,
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Material(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => setState(() {
                                    listenables.polygon.clear();
                                    _photoMarkers.clear();
                                  }),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.clear,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
              flex: 1,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(icon: Icon(Icons.info_outline), text: 'Info'),
                      Tab(icon: Icon(Icons.airplanemode_on), text: 'Aircraft'),
                      Tab(icon: Icon(Icons.photo_camera), text: 'Camera'),
                      Tab(icon: Icon(Icons.file_copy), text: 'File'),
                    ],
                  ),
                  Expanded(
                      child: TabBarView(
                          controller: _tabController,
                          children: const [
                        Info(),
                        AircraftBar(),
                        CameraBar(),
                        ExportBar()
                      ]))
                ],
              ))
        ];
        return Scaffold(
            appBar: const MappingAppBar(),
            body: MediaQuery.of(context).size.width < 700
                ? Column(
                    children: children,
                  )
                : Row(children: children));
      },
    );
  }
}

class MapSearchLocation {
  final String name;
  final String type;
  final LatLng location;

  MapSearchLocation(
      {required this.name, required this.type, required this.location});
}
