import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../data/waste_labels.dart';

class WastePopup extends StatelessWidget {
  final LatLng location;
  final List<String> wasteTypes;
  final String wasteForm;

  const WastePopup({
    super.key,
    required this.location,
    required this.wasteTypes,
    required this.wasteForm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(_getIconForForm(), color: const Color.fromARGB(255, 0, 0, 0)),
          const SizedBox(width: 8),
          Text(_getTitleForForm()),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '📍 Location: ${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
          ),
          const SizedBox(height: 12),
          const Text('Trash Types:'),
          const SizedBox(height: 4),
          ...(wasteTypes.isEmpty
              ? [const Text("• General Waste")]
              : wasteTypes
                  .map((w) => Text("• ${wasteTypeLabels[w] ?? w}"))
                  .toList()),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  IconData _getIconForForm() {
    switch (wasteForm) {
      case 'basket':
        return Icons.delete_outline;
      case 'container':
        return Icons.local_shipping;
      case 'centre':
        return Icons.home_repair_service;
      default:
        return Icons.help;
    }
  }

  String _getTitleForForm() {
    switch (wasteForm) {
      case 'basket':
        return 'Trash can';
      case 'container':
        return 'Container';
      case 'centre':
        return 'Recycling center';
      default:
        return 'unknown';
    }
  }
}
