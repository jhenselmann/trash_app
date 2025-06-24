import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/waste_popup.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../services/saved_trashcan_service.dart';
import '../services/user_trashcan_service.dart';

class WasteMarkerLoader {
  static Widget _buildMarkerIcon(String wasteForm, bool isSaved) {
    switch (wasteForm) {
      case 'basket':
        return Icon(Icons.delete_outline, size: 20, color: Colors.black);
      case 'container':
        return Image.asset(
          'assets/icons/container.png',
          width: 20,
          height: 20,
          color: Colors.black,
          colorBlendMode: BlendMode.srcIn,
        );
      case 'centre':
        return Icon(Icons.recycling, size: 20, color: Colors.black);
      default:
        return const Icon(Icons.help_outline, size: 20, color: Colors.grey);
    }
  }

  static Future<List<Marker>> loadMarkers(BuildContext context) async {
    final List<Marker> markers = [];

    // 1. Original aus JSON laden
    final jsonStr = await rootBundle.loadString('assets/waste_data.json');
    final data = json.decode(jsonStr);
    final originalItems = List<Map<String, dynamic>>.from(data['features']);

    // 2. User-Trashcans laden
    final userTrashcans = await UserTrashcanService.loadUserTrashcans();
    final userItems = userTrashcans.map((e) => e.toJson()).toList();

    // 3. Kombinieren
    final combined = [...originalItems, ...userItems];

    for (var item in combined) {
      final coords = item['coordinates'];
      final wasteTypes = item['wasteTypes'] ?? [];
      final wasteForm = item['wasteForm'] ?? 'unknown';
      final id = item['id'] ?? '';
      final addedByUser = item['addedByUser'] == true;

      if (wasteForm == 'unknown') continue;

      final latLng = LatLng(coords[1], coords[0]);
      final isSaved = await SavedTrashcanService.isSaved(id);

      print('ADDING MARKER: $id @ $latLng, user: $addedByUser');

      markers.add(
        Marker(
          key: ValueKey(id),
          point: latLng,
          width: 30,
          height: 30,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (_) => WastePopup(
                      id: id,
                      location: latLng,
                      wasteTypes: List<String>.from(wasteTypes),
                      wasteForm: wasteForm,
                      addedBy: item['addedBy'],
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
              child: _buildMarkerIcon(wasteForm, isSaved),
            ),
          ),
        ),
      );
    }

    return markers;
  }
}
