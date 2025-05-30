import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:trash_app/screens/confirm_trash_screen.dart';
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

  void _onSelectLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmTrashcanScreen(location: _userLocation),
      ),
    );
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
