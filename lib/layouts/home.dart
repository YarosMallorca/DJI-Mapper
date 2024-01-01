import 'package:dji_waypoint_mapping/layouts/aircraft.dart';
import 'package:dji_waypoint_mapping/layouts/camera.dart';
import 'package:dji_waypoint_mapping/layouts/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with TickerProviderStateMixin {
  final MapController mapController = MapController();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<LatLng> polygon = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 10,
          title: const Text('DJI Waypoint Mapping'),
        ),
        body: Row(
          children: [
            Flexible(
              flex: 3,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  onTap: (tapPosition, point) => {
                    setState(() {
                      polygon.add(point);
                    }),
                  },
                  initialCenter: const LatLng(39.586550, 3.374027),
                  initialZoom: 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.yaros.dji_waypoint_mapping',
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                            onTap: () => setState(() {
                                  polygon = [];
                                }),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.clear),
                            )),
                      ),
                    ),
                  ),
                  PolygonLayer(polygons: [
                    Polygon(
                        points: polygon,
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                        isFilled: true,
                        borderColor: Theme.of(context).colorScheme.primaryContainer,
                        borderStrokeWidth: 3),
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
                        Tab(icon: Icon(Icons.list), text: 'Mission'),
                        Tab(icon: Icon(Icons.photo_camera), text: 'Camera'),
                        Tab(icon: Icon(Icons.save), text: 'Export'),
                      ],
                    ),
                    Expanded(
                        child: TabBarView(
                            controller: _tabController, children: const [AircraftBar(), CameraBar(), ExportBar()]))
                  ],
                ))
          ],
        ));
  }
}
