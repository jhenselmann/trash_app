import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:trash_app/screens/trash_map_screen.dart';
import 'package:trash_app/services/saved_trashcan_service.dart';
import 'package:trash_app/screens/trashcan_detail_screen.dart';

class TrashcanTile extends StatefulWidget {
  final Map<String, dynamic> item;
  final LatLng? userLocation;
  final VoidCallback? onChanged; // NEU!

  const TrashcanTile({
    super.key,
    required this.item,
    this.userLocation,
    this.onChanged, // NEU
  });

  @override
  State<TrashcanTile> createState() => _TrashcanTileState();
}

class _TrashcanTileState extends State<TrashcanTile> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkSaved();
  }

  Future<void> _checkSaved() async {
    final saved = await SavedTrashcanService.isSaved(widget.item['id']);
    setState(() {
      _isSaved = saved;
    });
  }

  IconData _getIcon(String form) {
    switch (form) {
      case 'basket':
        return Icons.delete_outline;
      case 'container':
        return Icons.inventory_2_rounded;
      case 'centre':
        return Icons.recycling;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  Widget _actionButton(IconData icon, String label, VoidCallback? onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return const Text(
      '|',
      style: TextStyle(fontSize: 16, color: Colors.black38),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coords = widget.item['coordinates'];
    final form = widget.item['wasteForm'];
    final dist =
        widget.userLocation != null
            ? const Distance().as(
              LengthUnit.Meter,
              widget.userLocation!,
              LatLng(coords[1], coords[0]),
            )
            : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getIcon(form), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  form.toString().toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  dist != null
                      ? 'Distance: ${_formatDistance(dist)}'
                      : 'Distance: –',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _actionButton(Icons.map, "Map", () {
                final coords = widget.item['coordinates'];
                final target = LatLng(coords[1], coords[0]);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrashMapScreen(focusTrashcan: target),
                  ),
                );
              }),
              _verticalDivider(),
              _actionButton(Icons.alt_route, "Route", () {
                final coords = widget.item['coordinates'];
                final target = LatLng(coords[1], coords[0]);

                Posthog().capture(
                  eventName: 'route_started',
                  properties: {
                    'source': 'list',
                    'waste_form': widget.item['wasteForm'] ?? 'unknown',
                    'waste_types': widget.item['wasteTypes'] ?? [],
                    'added_by': widget.item['addedBy'] ?? 'unknown',
                  },
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => TrashMapScreen(
                          focusTrashcan: target,
                          routeToFocus: true,
                        ),
                  ),
                );
              }),
              _verticalDivider(),
              _actionButton(
                _isSaved ? Icons.bookmark : Icons.bookmark_border,
                "Save",
                () async {
                  await SavedTrashcanService.toggle(widget.item['id']);
                  await _checkSaved();

                  if (widget.onChanged != null) {
                    widget.onChanged!(); // Eltern benachrichtigen
                  }
                },
              ),

              _verticalDivider(),
              _actionButton(Icons.info_outline, "Details", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrashcanDetailScreen(item: widget.item),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
