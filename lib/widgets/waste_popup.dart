import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../data/waste_labels.dart';
import '../services/saved_trashcan_service.dart';

class WastePopup extends StatefulWidget {
  final String id; // NEU
  final LatLng location;
  final List<String> wasteTypes;
  final String wasteForm;

  const WastePopup({
    super.key,
    required this.id,
    required this.location,
    required this.wasteTypes,
    required this.wasteForm,
  });

  @override
  State<WastePopup> createState() => _WastePopupState();
}

class _WastePopupState extends State<WastePopup> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadSavedStatus();
  }

  Future<void> _loadSavedStatus() async {
    final isSaved = await SavedTrashcanService.isSaved(widget.id);
    if (mounted) {
      setState(() => _isSaved = isSaved);
    }
  }

  Future<void> _toggleSave() async {
    await SavedTrashcanService.toggle(widget.id);
    final updated = await SavedTrashcanService.isSaved(widget.id);

    if (mounted) {
      setState(() => _isSaved = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSaved ? 'Trashcan saved' : 'Trashcan unsaved'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _getIconForForm(),
              const SizedBox(width: 8),
              Text(_getTitleForForm()),
            ],
          ),
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.black87,
            ),
            tooltip: _isSaved ? 'Saved' : 'Save',
            onPressed: _toggleSave,
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '📍 Location: ${widget.location.latitude.toStringAsFixed(5)}, ${widget.location.longitude.toStringAsFixed(5)}',
          ),
          const SizedBox(height: 12),
          const Text('Trash Types:'),
          const SizedBox(height: 4),
          ...(widget.wasteTypes.isEmpty
              ? [const Text("• General Waste")]
              : widget.wasteTypes
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

  Widget _getIconForForm() {
    switch (widget.wasteForm) {
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
    switch (widget.wasteForm) {
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
