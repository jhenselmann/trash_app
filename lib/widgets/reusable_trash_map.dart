import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../data/waste_marker_loader.dart';
import '../services/routing_service.dart';

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
  LatLng? _userLocation;
  List<LatLng> _routePoints = [];
  bool _routeActive = false;
  double? _routeDistanceMeters;

  bool get routeActive => _routeActive;
  double? get routeDistanceMeters => _routeDistanceMeters;

  List<Marker> _allMarkers = [];

  List<Marker> get allMarkers => _allMarkers;
  LatLng? get userLocation => _userLocation;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadMarkers();
    widget.onMapControllerReady?.call(_mapController);
  }

  Future<void> _initLocation() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    location.onLocationChanged.listen((newLoc) {
      final loc = LatLng(newLoc.latitude!, newLoc.longitude!);
      setState(() {
        _userLocation = loc;
      });
      widget.onUserLocationUpdate(loc);
    });

    // fallback falls Location nicht liefert
    await Future.delayed(const Duration(seconds: 2));
    if (_userLocation == null) {
      setState(() {
        _userLocation = LatLng(48.137154, 11.576124); // München
      });
      widget.onUserLocationUpdate(_userLocation!);
    }
  }

  Future<void> _loadMarkers() async {
    final markers = await WasteMarkerLoader.loadMarkersFromJson(
      'assets/waste_data.json',
      context,
    );
    setState(() {
      _allMarkers = markers;
    });
  }

  void centerOnUser() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 16);
    }
  }

  Future<void> routeToNearestTrashcan() async {
    if (_userLocation == null) {
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
      final d = distance(_userLocation!, m.point);
      if (d < shortest) {
        shortest = d;
        nearest = m;
      }
    }

    if (nearest == null) return;

    try {
      final route = await RoutingService.fetchRoute(
        start: _userLocation!,
        end: nearest.point,
        profile: 'foot-walking',
      );

      setState(() {
        _routePoints = route;
        _routeActive = true;
        _routeDistanceMeters = const Distance().as(
          LengthUnit.Meter,
          _userLocation!,
          nearest!.point,
        );
      });

      _mapController.move(nearest.point, 16);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Route to nearest trash loaded.')),
      );
    } catch (e) {
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
    final visibleMarkers =
        widget.markerFilter?.call(_allMarkers) ?? _allMarkers;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _userLocation ?? LatLng(48.137154, 11.576124),
        initialZoom: widget.initialZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.trashApp',
        ),
        if (_userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _userLocation!,
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
