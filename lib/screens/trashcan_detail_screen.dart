import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_app/services/location_service.dart';
import 'package:latlong2/latlong.dart';

class TrashcanDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const TrashcanDetailScreen({super.key, required this.item});

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    final coords = item['coordinates'];
    final types = List<String>.from(item['wasteTypes'] ?? []);
    final form = item['wasteForm'];
    final userLocation = context.watch<LocationService>().currentLocation;

    double? distance;
    if (userLocation != null) {
      final target = LatLng(coords[1], coords[0]);
      distance = const Distance().as(LengthUnit.Meter, userLocation, target);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trashcan Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${form.toUpperCase()}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Location: ${coords[1].toStringAsFixed(5)}, ${coords[0].toStringAsFixed(5)}',
            ),
            const SizedBox(height: 12),
            if (distance != null)
              Text(
                'Entfernung: ${_formatDistance(distance)}',
                style: const TextStyle(color: Colors.black54),
              ),
            if (distance == null) const Text('Entfernung: –'),
            const SizedBox(height: 12),
            Text('Waste Types:'),
            const SizedBox(height: 4),
            ...types.map((type) => Text('- $type')),
          ],
        ),
      ),
    );
  }
}
