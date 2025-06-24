class Trashcan {
  final String id;
  final List<double> coordinates;
  final List<String> wasteTypes;
  final String wasteForm;
  final bool addedByUser;

  Trashcan({
    required this.id,
    required this.coordinates,
    required this.wasteTypes,
    required this.wasteForm,
    this.addedByUser = false,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "coordinates": coordinates,
    "wasteTypes": wasteTypes,
    "wasteForm": wasteForm,
    "addedByUser": addedByUser,
  };

  static Trashcan fromJson(Map<String, dynamic> json) => Trashcan(
    id: json["id"],
    coordinates: List<double>.from(json["coordinates"]),
    wasteTypes: List<String>.from(json["wasteTypes"]),
    wasteForm: json["wasteForm"],
    addedByUser: json["addedByUser"] ?? false,
  );
}
