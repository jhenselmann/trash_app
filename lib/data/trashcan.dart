import 'package:latlong2/latlong.dart';

class Trashcan {
  final String id;
  final List<double> coordinates;
  final List<String> wasteTypes;
  final String wasteForm;
  final bool addedByUser;
  final String? addedBy;

  Trashcan({
    required this.id,
    required this.coordinates,
    required this.wasteTypes,
    required this.wasteForm,
    this.addedByUser = false,
    String? addedBy,
  }) : addedBy = addedBy ?? 'You';

  double get latitude => coordinates[1];
  double get longitude => coordinates[0];
  LatLng get location => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() => {
    "id": id,
    "coordinates": coordinates,
    "wasteTypes": wasteTypes,
    "wasteForm": wasteForm,
    "addedByUser": addedByUser,
    "addedBy": addedBy, // <–– neu
  };

  static Trashcan fromJson(Map<String, dynamic> json) => Trashcan(
    id: json["id"],
    coordinates: List<double>.from(json["coordinates"]),
    wasteTypes: List<String>.from(json["wasteTypes"]),
    wasteForm: json["wasteForm"],
    addedByUser: json["addedByUser"] ?? false,
    addedBy: json["addedBy"],
  );
}
