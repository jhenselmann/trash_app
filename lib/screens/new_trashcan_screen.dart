import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trash_app/screens/addtrashcan/confirm_trash_screen.dart';
import '../widgets/reusable_trash_map.dart';
import '../widgets/LocationPin.dart';
import 'package:provider/provider.dart';
import 'package:trash_app/providers/trashcan_provider.dart';
import '../services/user_trashcan_service.dart';

class NewTrashcanScreen extends StatefulWidget {
  const NewTrashcanScreen({super.key});

  @override
  State<NewTrashcanScreen> createState() => _NewTrashcanScreenState();
}

class _NewTrashcanScreenState extends State<NewTrashcanScreen> {
  final GlobalKey<ReusableTrashMapState> _mapKey = GlobalKey();
  bool _showTrashMarkers = true;

  Future<void> _onSelectLocation() async {
    final selectedLocation = _mapKey.currentState?.getMapCenter();
    if (selectedLocation == null) return;

    final confirmed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmTrashcanScreen(location: selectedLocation),
      ),
    );

    if (confirmed is String && context.mounted) {
      final newId = confirmed;

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
                  const SizedBox(height: 16),
                  const Text(
                    "Trashcan added!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "The trashcan got added. Thank you. ",
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
                          child: const Text("Confirm"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await UserTrashcanService.deleteUserTrashcan(newId);
                            if (context.mounted) {
                              context.read<TrashcanProvider>().loadMarkers(
                                context,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Submission undone."),
                                ),
                              );
                            }
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

      context.read<TrashcanProvider>().loadMarkers(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ReusableTrashMap(
            onUserLocationUpdate: (_) {},
            key: _mapKey,
            enableClustering: true,
            markerFilter: _showTrashMarkers ? null : (_) => [],
          ),
          const Center(child: Locationpin()),

          // Select location
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

          // Center on user
          Positioned(
            top: 40,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'centerOnUser',
              onPressed: () {
                _mapKey.currentState?.centerOnUser();
              },
              backgroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),

          // Toggle markers
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
