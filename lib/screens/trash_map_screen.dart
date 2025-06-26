import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trash_app/screens/trashcan_list_screen.dart';
import 'package:trash_app/services/location_service.dart';
import '../providers/waste_filter_provider.dart';
import '../widgets/reusable_trash_map.dart';
import '../widgets/waste_type_filter.dart';

class TrashMapScreen extends StatefulWidget {
  final LatLng? focusTrashcan;
  final bool routeToFocus;

  const TrashMapScreen({
    super.key,
    this.focusTrashcan,
    this.routeToFocus = false,
  });

  @override
  State<TrashMapScreen> createState() => _TrashMapScreenState();
}

class _TrashMapScreenState extends State<TrashMapScreen> {
  final GlobalKey<ReusableTrashMapState> _mapKey = GlobalKey();
  DateTime? _screenStartTime;

  @override
  void initState() {
    super.initState();
    _screenStartTime = DateTime.now();
    Posthog().capture(
      eventName: 'screen_viewed',
      properties: {'screen': 'map', 'timestamp': _screenStartTime.toString()},
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.focusTrashcan != null) {
        _mapKey.currentState?.centerOnPoint(widget.focusTrashcan!);
        if (widget.routeToFocus) {
          _mapKey.currentState?.routeToPoint(widget.focusTrashcan!).then((_) {
            setState(() {});
          });
        }
      }
    });
  }

  @override
  void dispose() {
    final duration = DateTime.now().difference(_screenStartTime!);
    Posthog().capture(
      eventName: 'screen_left',
      properties: {'screen': 'map', 'duration_seconds': duration.inSeconds},
    );
    super.dispose();
  }

  List<Marker> _applyWasteTypeFilter(List<Marker> all) {
    final activeFilters = context.read<WasteFilterProvider>().filters;

    if (activeFilters.isEmpty) return all;

    return all.where((m) {
      final key = m.key;
      if (key is ValueKey<Map<String, dynamic>>) {
        final meta = key.value;
        final raw = meta['wasteTypes'];
        final types = raw is List ? raw.map((e) => e.toString()).toList() : [];
        return types.any((t) => activeFilters.contains(t));
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filters = context.watch<WasteFilterProvider>().filters;
    final routeActive = _mapKey.currentState?.routeActive ?? false;
    final routeDistance = _mapKey.currentState?.routeDistanceMeters;

    return Scaffold(
      body: Stack(
        children: [
          ReusableTrashMap(
            key: _mapKey,
            onUserLocationUpdate: (_) {},
            markerFilter: _applyWasteTypeFilter,
          ),

          // Standort-Zentrierung
          Positioned(
            top: 50,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'centerOnUser',
              onPressed: () => _mapKey.currentState?.centerOnUser(),
              backgroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),

          // Filter-Button (Provider-basiert)
          WasteTypeFilter(),

          if (routeActive && routeDistance != null)
            Positioned(
              top: 110,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${routeDistance.toStringAsFixed(0)} m bis zum Mülleimer',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),

          // Liste öffnen
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'list',
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.list, size: 35, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => TrashcanListScreen(
                          userLocation:
                              context.read<LocationService>().currentLocation,
                          activeFilters: filters,
                        ),
                  ),
                );
              },
            ),
          ),

          // Routing-Button
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'main',
              onPressed: () async {
                if (routeActive) {
                  Posthog().capture(eventName: 'route_cancelled');

                  _mapKey.currentState?.cancelRoute();
                  setState(() {});
                } else {
                  Posthog().capture(eventName: 'route_to_nearest_pressed');

                  await _mapKey.currentState?.routeToNearestTrashcan();
                  setState(() {});
                }
              },
              backgroundColor: routeActive ? Colors.red : Colors.white,
              shape: const CircleBorder(),
              child: Icon(
                routeActive ? Icons.close : Icons.alt_route,
                size: 35,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
