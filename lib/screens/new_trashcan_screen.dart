import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trash_app/screens/addtrashcan/confirm_trash_screen.dart';
import '../widgets/reusable_trash_map.dart';
import '../widgets/LocationPin.dart';

class NewTrashcanScreen extends StatefulWidget {
  const NewTrashcanScreen({super.key});

  @override
  State<NewTrashcanScreen> createState() => _NewTrashcanScreenState();
}

class _NewTrashcanScreenState extends State<NewTrashcanScreen> {
  LatLng _userLocation = LatLng(52.52, 13.405);
  bool _showTrashMarkers = true;
  MapController? _mapController;

  Future<void> _onSelectLocation() async {
    final confirmed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmTrashcanScreen(location: _userLocation),
      ),
    );

    if (confirmed == true && context.mounted) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.eco, color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    "Thank you!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Your contribution makes a real difference 🌍\n\nThanks to people like you, this app can grow – and the planet gets a little cleaner.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Keep going!"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Submission undone."),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Undo"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      );
    }
  }

  void _moveToUser() {
    if (_mapController != null) {
      _mapController!.move(_userLocation, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ReusableTrashMap(
            onUserLocationUpdate: (loc) {
              _userLocation = loc;
            },
            enableClustering: true,
            markerFilter: _showTrashMarkers ? null : (_) => [],
            onMapControllerReady: (controller) {
              _mapController = controller;
            },
            initialZoom: 18,
          ),
          const Center(child: Locationpin()),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _onSelectLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Select Location'),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'centerOnUser',
              onPressed: _moveToUser,
              backgroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),

          Positioned(
            top: 40,
            left: 20,
            child: FloatingActionButton(
              heroTag: 'toggleTrashMarkers',
              onPressed: () {
                setState(() {
                  _showTrashMarkers = !_showTrashMarkers;
                });
              },
              backgroundColor: Colors.white,
              mini: true,
              child: Icon(
                _showTrashMarkers ? Icons.delete : Icons.delete_forever,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
