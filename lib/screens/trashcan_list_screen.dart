import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:trash_app/providers/waste_filter_provider.dart';
import 'package:trash_app/services/user_trashcan_service.dart';
import 'dart:convert';

import 'package:trash_app/widgets/trashcan_tile.dart';
import '../widgets/waste_type_filter.dart';

class TrashcanListScreen extends StatefulWidget {
  final LatLng? userLocation;
  final Set<String> activeFilters; // bleibt nur für initialen Push
  const TrashcanListScreen({
    super.key,
    required this.userLocation,
    required this.activeFilters,
  });

  @override
  State<TrashcanListScreen> createState() => _TrashcanListScreenState();
}

class _TrashcanListScreenState extends State<TrashcanListScreen> {
  final int _itemsPerPage = 50;
  int _currentPage = 0;
  List<Map<String, dynamic>> _allTrashcans = [];
  List<Map<String, dynamic>> _visibleTrashcans = [];

  @override
  void initState() {
    super.initState();

    // Init Filter einmalig übernehmen (optional)
    final filterProvider = context.read<WasteFilterProvider>();
    if (filterProvider.filters.isEmpty && widget.activeFilters.isNotEmpty) {
      filterProvider.updateFilters(widget.activeFilters);
    }

    _loadTrashcans();
  }

  Future<void> _loadTrashcans() async {
    final jsonStr = await rootBundle.loadString('assets/waste_data.json');
    final data = json.decode(jsonStr);
    final features = List<Map<String, dynamic>>.from(data['features']);

    final userTrashcans = await UserTrashcanService.loadUserTrashcans();
    final userTrashcanMaps =
        userTrashcans
            .map(
              (t) => {
                'id': t.id,
                'coordinates': [t.longitude, t.latitude],
                'wasteTypes': t.wasteTypes,
                'wasteForm': t.wasteForm,
                'addedBy': t.addedBy ?? 'You',
              },
            )
            .toList();

    final combined = [...features, ...userTrashcanMaps];

    final userLoc = widget.userLocation;
    if (userLoc != null) {
      final dist = const Distance();
      combined.sort((a, b) {
        final aCoord = LatLng(a['coordinates'][1], a['coordinates'][0]);
        final bCoord = LatLng(b['coordinates'][1], b['coordinates'][0]);
        return dist(userLoc, aCoord).compareTo(dist(userLoc, bCoord));
      });
    }

    setState(() {
      _allTrashcans = combined;
    });

    _updateVisibleList(); // initial laden
  }

  void _updateVisibleList() {
    final filters = context.read<WasteFilterProvider>().filters;
    final start = _currentPage * _itemsPerPage;

    final filtered =
        _allTrashcans.where((item) {
          if (filters.isEmpty) return true;
          final types = List<String>.from(item['wasteTypes'] ?? []);
          return types.any(filters.contains);
        }).toList();

    setState(() {
      _visibleTrashcans = filtered.skip(start).take(_itemsPerPage).toList();
    });
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
    _updateVisibleList();
  }

  void _previousPage() {
    if (_currentPage == 0) return;
    setState(() {
      _currentPage--;
    });
    _updateVisibleList();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateVisibleList());

    return Scaffold(
      body: Column(
        children: [
          const WasteTypeFilter(),
          Expanded(
            child:
                _visibleTrashcans.isEmpty
                    ? const Center(child: Text('Keine Mülleimer gefunden.'))
                    : ListView.builder(
                      itemCount: _visibleTrashcans.length,
                      itemBuilder: (context, index) {
                        return TrashcanTile(
                          item: _visibleTrashcans[index],
                          userLocation: widget.userLocation,
                        );
                      },
                    ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: _previousPage,
                child: const Text('Previous'),
              ),
              Text('Page ${_currentPage + 1}'),
              TextButton(onPressed: _nextPage, child: const Text('Next')),
            ],
          ),
        ],
      ),
    );
  }
}
