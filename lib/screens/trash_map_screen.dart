import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../widgets/reusable_trash_map.dart';
import '../widgets/waste_type_list.dart';

class TrashMapScreen extends StatefulWidget {
  const TrashMapScreen({super.key});

  @override
  State<TrashMapScreen> createState() => _TrashMapScreenState();
}

class _TrashMapScreenState extends State<TrashMapScreen> {
  final GlobalKey<ReusableTrashMapState> _mapKey = GlobalKey();
  Set<String> _activeWasteFilters = {};

  List<Marker> _applyWasteTypeFilter(List<Marker> all) {
    if (_activeWasteFilters.isEmpty) return all;

    return all.where((m) {
      final key = m.key;
      if (key is ValueKey<Map<String, dynamic>>) {
        final meta = key.value;
        final raw = meta['wasteTypes'];
        final types = raw is List ? raw.map((e) => e.toString()).toList() : [];
        return types.any((t) => _activeWasteFilters.contains(t));
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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

          // Filter-Button
          Positioned(
            top: 50,
            left: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 4,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => WasteTypeListPopup(
                        selected: _activeWasteFilters,
                        onChanged: (updated) {
                          setState(() {
                            _activeWasteFilters = updated;
                          });
                        },
                      ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text("Filter"),
            ),
          ),

          // "Clear Filters"-Button unter dem Filter-Button
          if (_activeWasteFilters.isNotEmpty)
            Positioned(
              top: 100,
              left: 20,
              child: SizedBox(
                height: 32,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _activeWasteFilters.clear();
                    });
                  },
                  child: const Text("Clear filters"),
                ),
              ),
            ),

          // Aktive Filter-Chips anzeigen
          if (_activeWasteFilters.isNotEmpty)
            Positioned(
              top: 50,
              left: 130, // Platz für Filter-Button
              right: 80, // Platz für Standort-Button
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _activeWasteFilters.map((filter) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber[100], // 🌟 Heller Gelbton
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    filter,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _activeWasteFilters.remove(filter);
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),

          // Entfernung anzeigen (falls aktiv)
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

          // Dynamischer Button unten rechts
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'main',
              onPressed: () async {
                if (routeActive) {
                  _mapKey.currentState?.cancelRoute();
                  setState(() {});
                } else {
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
