import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/waste_popup.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class WasteMarkerLoader {
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

      IconData icon;
      switch (wasteForm) {
        case 'basket':
          icon = Icons.delete_outline;
          break;
        case 'container':
          icon = Icons.local_shipping;
          break;
        case 'centre':
          icon = Icons.home_repair_service;
          break;
        default:
          continue;
      }

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
              child: Center(child: Icon(icon, size: 20, color: Colors.black)),
            ),
          ),
        ),
      );
    }

    return markers;
  }
}
