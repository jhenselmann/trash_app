import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import '../data/waste_marker_loader.dart';
import '../services/routing_service.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';

typedef MarkerFilter = List<Marker> Function(List<Marker> all);

class ReusableTrashMap extends StatefulWidget {
  final Function(LatLng) onUserLocationUpdate;
  final MarkerFilter? markerFilter;
  final bool enableClustering;
  final void Function(MapController)? onMapControllerReady;
  final double initialZoom;

  const ReusableTrashMap({
    super.key,
    required this.onUserLocationUpdate,
    this.markerFilter,
    this.enableClustering = true,
    this.onMapControllerReady,
    this.initialZoom = 14,
  });

  @override
  State<ReusableTrashMap> createState() => ReusableTrashMapState();
}

class ReusableTrashMapState extends State<ReusableTrashMap> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  bool _routeActive = false;
  double? _routeDistanceMeters;

  List<Marker> _allMarkers = [];

  bool get routeActive => _routeActive;
  double? get routeDistanceMeters => _routeDistanceMeters;
  List<Marker> get allMarkers => _allMarkers;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    widget.onMapControllerReady?.call(_mapController);
  }

  Future<void> _loadMarkers() async {
    final markers = await WasteMarkerLoader.loadMarkersFromJson(
      'assets/waste_data.json',
      context,
    );
    if (!mounted) return;
    setState(() {
      _allMarkers = markers;
    });
  }

  void centerOnUser() {
    final userLocation = context.read<LocationService>().currentLocation;
    if (userLocation != null) {
      _mapController.move(userLocation, 16);
    }
  }

  Future<void> routeToNearestTrashcan() async {
    final userLocation = context.read<LocationService>().currentLocation;
    if (userLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No location found')));
      return;
    }

    final visible = widget.markerFilter?.call(_allMarkers) ?? _allMarkers;
    if (visible.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No trashcan found')));
      return;
    }

    final distance = const Distance();
    Marker? nearest;
    double shortest = double.infinity;

    for (final m in visible) {
      final d = distance(userLocation, m.point);
      if (d < shortest) {
        shortest = d;
        nearest = m;
      }
    }

    if (nearest == null) return;

    try {
      final route = await RoutingService.fetchRoute(
        start: userLocation,

        end: nearest.point,
        profile: 'foot-walking',
      );

      if (!mounted) return;

      setState(() {
        _routePoints = route;
        _routeActive = true;
        _routeDistanceMeters = distance(userLocation, nearest!.point);
      });

      _mapController.move(nearest.point, 16);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Route to nearest trash loaded.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error while loading nearest route.')),
      );
    }
  }

  void cancelRoute() {
    setState(() {
      _routePoints.clear();
      _routeDistanceMeters = null;
      _routeActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userLocation = context.watch<LocationService>().currentLocation;
    final visibleMarkers =
        widget.markerFilter?.call(_allMarkers) ?? _allMarkers;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: userLocation ?? LatLng(48.137154, 11.576124),
        initialZoom: widget.initialZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.trashApp',
        ),
        if (userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: userLocation,
                width: 20,
                height: 20,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        if (widget.enableClustering)
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 45,
              size: const Size(40, 40),
              markers: visibleMarkers,
              polygonOptions: PolygonOptions(
                borderColor: Colors.blueAccent,
                color: Colors.black12,
                borderStrokeWidth: 2,
              ),
              builder:
                  (context, markers) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.deepOrange,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      markers.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            ),
          )
        else
          MarkerLayer(markers: visibleMarkers),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 4,
                color: Colors.blue,
              ),
            ],
          ),
      ],
    );
  }
}
