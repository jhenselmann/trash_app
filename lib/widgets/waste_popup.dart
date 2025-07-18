import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trash_app/screens/trash_map_screen.dart';
import 'package:trash_app/widgets/trashcan_info_view.dart';
import '../services/saved_trashcan_service.dart';

class WastePopup extends StatefulWidget {
  final String id; // NEU
  final LatLng location;
  final List<String> wasteTypes;
  final String wasteForm;
  final String? addedBy;
  final NavigatorState navigator;

  const WastePopup({
    super.key,
    required this.id,
    required this.location,
    required this.wasteTypes,
    required this.wasteForm,
    this.addedBy,
    required this.navigator,
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
            padding: EdgeInsets.zero,
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.black87,
              size: 20,
            ),
            tooltip: _isSaved ? 'Saved' : 'Save',
            onPressed: _toggleSave,
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: SingleChildScrollView(
          child: TrashcanInfoView(
            location: widget.location,
            wasteTypes: widget.wasteTypes,
            wasteForm: widget.wasteForm,
            addedBy: widget.addedBy,
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      actions: [
        Row(
          children: [
            TextButton.icon(
              icon: const Icon(Icons.alt_route, size: 18),
              label: const Text('Route'),
              onPressed: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 100), () {
                  widget.navigator.push(
                    MaterialPageRoute(
                      builder:
                          (_) => TrashMapScreen(
                            focusTrashcan: widget.location,
                            routeToFocus: true,
                          ),
                    ),
                  );
                });
              },
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
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
