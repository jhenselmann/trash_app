import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trash_app/services/saved_trashcan_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class SavedTrashcansPage extends StatefulWidget {
  const SavedTrashcansPage({super.key});

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
    final allIds = await SavedTrashcanService.getSavedTrashcanIds();

    final jsonStr = await rootBundle.loadString('assets/waste_data.json');
    final data = json.decode(jsonStr);
    final allFeatures = data['features'] as List;

    final filtered =
        allFeatures.where((item) => allIds.contains(item['id'])).toList();

    setState(() {
      _savedTrashcans = List<Map<String, dynamic>>.from(filtered);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Trashcans')),
      body:
          _savedTrashcans.isEmpty
              ? const Center(child: Text('No saved trashcans yet.'))
              : ListView.builder(
                itemCount: _savedTrashcans.length,
                itemBuilder: (context, index) {
                  final item = _savedTrashcans[index];
                  final coords = item['coordinates'];
                  final types =
                      item['wasteTypes']?.join(', ') ?? 'General waste';
                  final form = item['wasteForm'];

                  return ListTile(
                    leading: Icon(_getIcon(form)),
                    title: Text(form.toString().toUpperCase()),
                    subtitle: Text(
                      '📍 ${coords[1].toStringAsFixed(5)}, ${coords[0].toStringAsFixed(5)}\nTypes: $types',
                    ),
                    isThreeLine: true,
                  );
                },
              ),
    );
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
}
