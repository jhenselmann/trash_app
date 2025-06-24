import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trash_app/data/waste_labels.dart';

class TrashcanInfoView extends StatelessWidget {
  final LatLng location;
  final List<String> wasteTypes;
  final String wasteForm;
  final double? distance;
  final String? addedBy;

  const TrashcanInfoView({
    super.key,
    required this.location,
    required this.wasteTypes,
    required this.wasteForm,
    this.distance,
    this.addedBy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type: ${wasteForm.toUpperCase()}'),
        const SizedBox(height: 8),
        Text(
          '📍 Location: ${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
        ),
        if (distance != null) Text('Distance: ${_formatDistance(distance!)}'),
        const SizedBox(height: 8),
        const Text('Waste Types:'),
        const SizedBox(height: 4),
        ...(wasteTypes.isEmpty
            ? [const Text("• General Waste")]
            : wasteTypes
                .map((w) => Text("• ${wasteTypeLabels[w] ?? w}"))
                .toList()),

        if (addedBy != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.redAccent, size: 18),
              const SizedBox(width: 6),
              Text(
                'Added by $addedBy',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatDistance(double d) {
    return d < 1000
        ? '${d.toStringAsFixed(0)} m'
        : '${(d / 1000).toStringAsFixed(1)} km';
  }
}
