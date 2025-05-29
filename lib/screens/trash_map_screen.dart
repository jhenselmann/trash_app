import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../data/waste_marker_loader.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import '../widgets/waste_type_list.dart';

class TrashMapScreen extends StatefulWidget {
  const TrashMapScreen({super.key});

  @override
  State<TrashMapScreen> createState() => _TrashMapScreenState();
}

class _TrashMapScreenState extends State<TrashMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  bool _showWasteTypeButtons = false;
  Set<String> _activeWasteFilters = {};
  List<Marker> _allMarkers = [];
  List<Marker> get _visibleWasteMarkers {
    if (_activeWasteFilters.isEmpty) return _allMarkers;
    return _allMarkers.where((m) {
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

  final Map<String, IconData> _wasteIcons = {
    'plastik': Icons.local_drink,
    'papier': Icons.description,
    'kleidung': Icons.checkroom,
    'glas': Icons.wine_bar,
  };

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadWasteData();
  }

  Future<void> _loadWasteData() async {
    final markers = await WasteMarkerLoader.loadMarkersFromJson(
      'assets/waste_data.json',
      context,
    );

    setState(() {
      _allMarkers = markers;
    });
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

      setState(() {
        _userLocation = LatLng(newLocation.latitude!, newLocation.longitude!);
      });
    });
  }

  void _moveToUser() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
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
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  markers: _visibleWasteMarkers,
                  polygonOptions: PolygonOptions(
                    borderColor: Colors.blueAccent,
                    color: Colors.black12,
                    borderStrokeWidth: 2,
                  ),
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        markers.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          Positioned(
            top: 50,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 4,
              ),
              onPressed: _moveToUser,
              child: const Icon(Icons.my_location, size: 25),
            ),
          ),

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

          Positioned(
            bottom: 30,
            right: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _showWasteTypeButtons = true;
                    });
                  },
                  child: FloatingActionButton(
                    heroTag: 'main',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Route to next trashcan (not implemented yet). ',
                          ),
                        ),
                      );
                    },
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.delete,
                      size: 35,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
