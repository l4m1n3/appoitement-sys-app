// models/zone_pointage.dart
class ZonePointage {
  final double latitude;
  final double longitude;
  final double rayonMetres;

  ZonePointage({
    required this.latitude,
    required this.longitude,
    required this.rayonMetres,
  });

  factory ZonePointage.fromJson(Map<String, dynamic> json) {
    return ZonePointage(
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      rayonMetres: double.parse(json['rayon_metres'].toString()),
    );
  }
}