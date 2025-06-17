import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class LocationService extends ChangeNotifier {
  final Location _location = Location();
  LatLng? _currentLocation;
  StreamSubscription<LocationData>? _locationSub;

  LatLng? get currentLocation => _currentLocation;

  LocationService() {
    _init();
  }

  Future<void> _init() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationSub = _location.onLocationChanged.listen((loc) {
      _currentLocation = LatLng(loc.latitude!, loc.longitude!);
      notifyListeners();
    });

    // Fallback einmalig setzen
    await Future.delayed(const Duration(seconds: 2));
    if (_currentLocation == null) {
      _currentLocation = LatLng(48.137154, 11.576124); // München
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    super.dispose();
  }
}
