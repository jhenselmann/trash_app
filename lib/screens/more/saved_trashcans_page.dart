import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:trash_app/services/saved_trashcan_service.dart';
import 'package:trash_app/widgets/trashcan_tile.dart';
import 'package:provider/provider.dart';
import 'package:trash_app/services/location_service.dart';

class SavedTrashcansPage extends StatefulWidget {
  final LatLng? userLocation;

  const SavedTrashcansPage({super.key, this.userLocation});

  @override
  State<SavedTrashcansPage> createState() => _SavedTrashcansPageState();
}

class _SavedTrashcansPageState extends State<SavedTrashcansPage> {
  List<Map<String, dynamic>> _savedTrashcans = [];

  @override
  void initState() {
    super.initState();
    _loadSavedTrashcans();
  }

  Future<void> _loadSavedTrashcans() async {
    final savedIds = await SavedTrashcanService.getSavedTrashcanIds();
    final jsonStr = await rootBundle.loadString('assets/waste_data.json');
    final data = json.decode(jsonStr);
    final all = List<Map<String, dynamic>>.from(data['features']);
    final filtered =
        all.where((item) => savedIds.contains(item['id'])).toList();

    setState(() {
      _savedTrashcans = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userLocation = context.watch<LocationService>().currentLocation;
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Trashcans')),
      body:
          _savedTrashcans.isEmpty
              ? const Center(child: Text('No saved trashcans yet.'))
              : ListView.builder(
                itemCount: _savedTrashcans.length,
                itemBuilder: (context, index) {
                  final item = _savedTrashcans[index];
                  return TrashcanTile(
                    key: ValueKey(item['id']), // ← WICHTIG!
                    item: item,
                    userLocation: userLocation,
                    onChanged: _loadSavedTrashcans,
                  );
                },
              ),
    );
  }
}
