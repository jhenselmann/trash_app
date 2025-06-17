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
          _getIconForForm(), // ← ersetzt: Icon(...)
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

  /// Liefert je nach Typ ein Icon oder Bild zurück
  Widget _getIconForForm() {
    switch (wasteForm) {
      case 'basket':
        return const Icon(Icons.delete_outline, color: Colors.black);
      case 'container':
        return Image.asset('assets/icons/container.png', width: 24, height: 24);
      case 'centre':
        return const Icon(Icons.recycling, color: Colors.black);
      default:
        return const Icon(Icons.help, color: Colors.grey);
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
        return 'Unknown';
    }
  }
}
