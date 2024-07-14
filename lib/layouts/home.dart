import 'package:dji_waypoint_mapping/components/app_bar.dart';
import 'package:dji_waypoint_mapping/core/drone_mapping_engine.dart';
import 'package:dji_waypoint_mapping/layouts/aircraft.dart';
import 'package:dji_waypoint_mapping/layouts/camera.dart';
import 'package:dji_waypoint_mapping/layouts/export.dart';
import 'package:dji_waypoint_mapping/layouts/info.dart';
import 'package:dji_waypoint_mapping/shared/value_listeneables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with TickerProviderStateMixin {
  final MapController mapController = MapController();
  late final TabController _tabController;

  final List<Marker> _photoMarkers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

    var waypoints = droneMapping.generateWaypoints(listenables.polygon);
    listenables.photoLocations = waypoints;
    if (waypoints.isEmpty) return;
    _photoMarkers.clear();
    for (var photoLocation in waypoints) {
      _photoMarkers.add(Marker(
          point: photoLocation,
          alignment: Alignment.center,
          rotate: false,
          child: Center(
            child: Icon(Icons.photo_camera,
                size: 25, color: Theme.of(context).colorScheme.tertiary),
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
            listenables.flightLine = null;
          }
        });

        var children = [
          Flexible(
            flex: MediaQuery.of(context).size.width < 700 ? 1 : 2,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                onTap: (tapPosition, point) => {
                  setState(() {
                    listenables.polygon.add(point);
                  }),
                },
                initialCenter: const LatLng(39.586550, 3.374027),
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  tileBuilder: Theme.of(context).brightness == Brightness.dark
                      ? (context, tileWidget, tile) =>
                          darkModeTileBuilder(context, tileWidget, tile)
                      : null,
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.yarosfpv.dji_mapper',
                ),
                PolygonLayer(polygons: [
                  Polygon(
                      points: listenables.polygon,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3),
                      isFilled: true,
                      borderColor: Theme.of(context).colorScheme.primary,
                      borderStrokeWidth: 3),
                ]),
                if (listenables.showCameras)
                  MarkerLayer(markers: _photoMarkers),
                PolylineLayer(polylines: [
                  listenables.flightLine ?? Polyline(points: [])
                ]),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      Tab(icon: Icon(Icons.save_alt), text: 'Export'),
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
