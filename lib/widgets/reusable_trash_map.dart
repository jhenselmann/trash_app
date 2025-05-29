// widgets/reusable_trash_map.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import '../data/waste_marker_loader.dart';

typedef MarkerFilter = List<Marker> Function(List<Marker> all);

class ReusableTrashMap extends StatefulWidget {
  final Function(LatLng) onUserLocationUpdate;
  final MarkerFilter? markerFilter;
  final bool enableClustering;
  final void Function(MapController)? onMapControllerReady;

  const ReusableTrashMap({
    super.key,
    required this.onUserLocationUpdate,
    this.markerFilter,
    this.enableClustering = true,
    this.onMapControllerReady,
  });

  @override
  State<ReusableTrashMap> createState() => _ReusableTrashMapState();
}

class _ReusableTrashMapState extends State<ReusableTrashMap> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  List<Marker> _allMarkers = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadMarkers();

    if (widget.onMapControllerReady != null) {
      widget.onMapControllerReady!(_mapController);
    }
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

    location.onLocationChanged.listen((newLocation) {
      if (!mounted) return;
      final loc = LatLng(newLocation.latitude!, newLocation.longitude!);

      setState(() {
        _userLocation = loc;
      });

      widget.onUserLocationUpdate(loc);
    });
  }

  Future<void> _loadMarkers() async {
    final markers = await WasteMarkerLoader.loadMarkersFromJson(
      'assets/waste_data.json',
      context,
    );

    if (mounted) {
      setState(() {
        _allMarkers = markers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleMarkers =
        widget.markerFilter?.call(_allMarkers) ?? _allMarkers;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _userLocation ?? LatLng(48.137154, 11.576124),
        initialZoom: 14,
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
      ],
    );
  }
}
