import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // ← Wichtig!
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

          // Route zum nächsten Mülleimer
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'main',
              onPressed: () => _mapKey.currentState?.routeToNearestTrashcan(),
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.delete, size: 35, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
