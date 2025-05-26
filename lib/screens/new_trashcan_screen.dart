import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/LocationPin.dart';

class NewTrashcanScreen extends StatefulWidget {
  const NewTrashcanScreen({super.key});

  @override
  State<NewTrashcanScreen> createState() => _NewTrashcanScreenState();
}

// Dummy next page
class NextPage extends StatelessWidget {
  final LatLng userLocation;

  const NextPage({required this.userLocation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Confirm Location")),
      body: Center(
        child: Text(
          "Selected location: ${userLocation.latitude}, ${userLocation.longitude}",
        ),
      ),
    );
  }
}

class _NewTrashcanScreenState extends State<NewTrashcanScreen> {
  final MapController _mapController = MapController();
  late LatLng _userLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _userLocation,
              zoom: 16.0,
              onPositionChanged: (position, _) {
                _userLocation = position.center!;
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.trashApp',
              ),
            ],
          ),

          // Center Icon
          Center(child: Locationpin()),

          // "Select Location" Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _onSelectLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Select Location'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _userLocation = LatLng(52.52, 13.405);
  }

  void _onSelectLocation() {
    // Navigate to the next page, passing the selected location
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NextPage(userLocation: _userLocation),
      ),
    );
  }
}
