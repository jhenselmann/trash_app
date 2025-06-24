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
    final addedBy = item['addedBy'] as String?;
    final userLocation = context.watch<LocationService>().currentLocation;

    double? distance;
    if (userLocation != null) {
      final target = LatLng(coords[1], coords[0]);
      distance = const Distance().as(LengthUnit.Meter, userLocation, target);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trashcan Details'),
        centerTitle: true,
        backgroundColor: Colors.yellow.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconForForm(form),
                    const SizedBox(width: 12),
                    Text(
                      _titleForForm(form),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '📍 Location:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${coords[1].toStringAsFixed(5)}, ${coords[0].toStringAsFixed(5)}',
                ),
                const Divider(height: 24),
                Text(
                  '♻️ Waste Types:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                ...types.map((type) => Text('- $type')),
                const Divider(height: 24),
                Text(
                  '📏 Distance:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  distance != null ? _formatDistance(distance) : '–',
                  style: const TextStyle(color: Colors.black54),
                ),

                // ❤️ Added by section
                if (addedBy != null) ...[
                  const Divider(height: 32),
                  Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Added by $addedBy',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Icon _iconForForm(String form) {
    switch (form) {
      case 'basket':
        return const Icon(Icons.delete_outline, size: 28, color: Colors.grey);
      case 'container':
        return const Icon(
          Icons.local_shipping_outlined,
          size: 28,
          color: Colors.blueGrey,
        );
      case 'centre':
        return const Icon(Icons.recycling, size: 28, color: Colors.green);
      default:
        return const Icon(Icons.help_outline, size: 28);
    }
  }

  String _titleForForm(String form) {
    switch (form) {
      case 'basket':
        return 'Trash Can';
      case 'container':
        return 'Container';
      case 'centre':
        return 'Recycling Center';
      default:
        return 'Unknown';
    }
  }
}
