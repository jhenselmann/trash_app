import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../data/waste_marker_loader.dart';

class TrashcanProvider extends ChangeNotifier {
  List<Marker> markers = [];

  Future<void> loadMarkers(BuildContext context) async {
    markers = await WasteMarkerLoader.loadMarkers(context);
    notifyListeners();
  }
}
