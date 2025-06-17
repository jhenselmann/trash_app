import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/waste_popup.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class WasteMarkerLoader {
  static Widget _buildMarkerIcon(String wasteForm) {
    switch (wasteForm) {
      case 'basket':
        return const Icon(Icons.delete_outline, size: 20, color: Colors.black);
      case 'container':
        return Image.asset('assets/icons/container.png', width: 20, height: 20);
      case 'centre':
        return const Icon(Icons.recycling, size: 20, color: Colors.black);
      default:
        return const Icon(Icons.help_outline, size: 20, color: Colors.grey);
    }
  }

  static Future<List<Marker>> loadMarkersFromJson(
    String assetPath,
    BuildContext context,
  ) async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final data = json.decode(jsonStr);

    final List<Marker> markers = [];

    for (var item in data['features']) {
      final coords = item['coordinates'];
      final wasteTypes = item['wasteTypes'] ?? [];
      final wasteForm = item['wasteForm'] ?? 'unknown';

      if (wasteForm == 'unknown') continue;

      final latLng = LatLng(coords[1], coords[0]);

      markers.add(
        Marker(
          key: ValueKey({'wasteTypes': wasteTypes, 'wasteForm': wasteForm}),
          point: latLng,
          width: 30,
          height: 30,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (_) => WastePopup(
                      location: latLng,
                      wasteTypes: List<String>.from(wasteTypes),
                      wasteForm: wasteForm,
                    ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMarkerIcon(wasteForm),
            ),
          ),
        ),
      );
    }

    return markers;
  }
}
