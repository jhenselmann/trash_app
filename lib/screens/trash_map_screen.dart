import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:math';

class TrashMapScreen extends StatefulWidget {
  const TrashMapScreen({super.key});

  @override
  State<TrashMapScreen> createState() => _TrashMapScreenState();
}

class _TrashMapScreenState extends State<TrashMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  bool _showWasteTypeButtons = false;

  final Map<String, IconData> _wasteIcons = {
    'plastik': Icons.local_drink, // PET-Flasche
    'papier': Icons.description, // Dokument
    'kleidung': Icons.checkroom, // T-Shirt
    'glas': Icons.wine_bar, // Glasflasche
  };

  @override
  void initState() {
    super.initState();
    _initLocation();
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

    // ⏱️ Abonniere kontinuierliche Standortänderungen
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
              initialCenter: _userLocation ?? LatLng(52.52, 13.405),
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
            ],
          ),

          // 🧭 Der Button oben rechts
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
            bottom: 30,
            right: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Viertelkreis Buttons
                if (_showWasteTypeButtons)
                  ..._wasteIcons.entries.toList().asMap().entries.map((entry) {
                    final i = entry.key;
                    final type = entry.value.key;
                    final icon = entry.value.value;

                    final angle = (-20 + i * 40) * pi / 180; // 25° Abstand
                    final radius = 70.0;

                    final dx = radius * cos(angle);
                    final dy = radius * sin(angle);

                    return Transform.translate(
                      offset: Offset(
                        -dx,
                        -dy,
                      ), // Richtung oben/links relativ zur Mitte
                      child: FloatingActionButton(
                        heroTag: type,
                        mini: true,
                        shape: const CircleBorder(),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        onPressed: () {
                          print('🗑️ Filter: $type');
                        },
                        child: Icon(icon),
                      ),
                    );
                  }),

                // Haupt-Button
                GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _showWasteTypeButtons = true;
                    });
                  },
                  onLongPressEnd: (_) {
                    setState(() {
                      _showWasteTypeButtons = false;
                    });
                  },
                  child: FloatingActionButton(
                    heroTag: 'main',
                    onPressed: () {
                      print('📍 Gehe zum nächsten Mülleimer...');
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
