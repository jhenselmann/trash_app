import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  static const String _apiKey = '';
  static const String _baseUrl =
      'https://api.openrouteservice.org/v2/directions';

  static Future<List<LatLng>> fetchRoute({
    required LatLng start,
    required LatLng end,
    String profile = 'foot-walking', // andere: 'cycling-regular', 'driving-car'
  }) async {
    final url = Uri.parse('$_baseUrl/$profile/geojson');

    final body = json.encode({
      'coordinates': [
        [start.longitude, start.latitude],
        [end.longitude, end.latitude],
      ],
    });

    final response = await http.post(
      url,
      headers: {'Authorization': _apiKey, 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coordinates = data['features'][0]['geometry']['coordinates'];
      return coordinates
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList();
    } else {
      throw Exception('Fehler beim Abrufen der Route');
    }
  }
}
