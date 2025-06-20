class AttendanceModel {
  final String type;
  final DateTime waktu;
  final double latitude;
  final double longitude;

  AttendanceModel({
    required this.type,
    required this.waktu,
    required this.latitude,
    required this.longitude,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      type: json['type'],
      waktu: DateTime.parse(json['waktu']),
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'waktu': waktu.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
  };
}
