class AttendanceModel {
  final int id;
  final String userNip;
  final String type;
  final DateTime waktu;
  final double latitude;
  final double longitude;
  final int lateDuration;
  final int overtimeDuration;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AttendanceModel({
    required this.id,
    required this.userNip,
    required this.type,
    required this.waktu,
    required this.latitude,
    required this.longitude,
    required this.lateDuration,
    required this.overtimeDuration,
    this.createdAt,
    this.updatedAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: _parseToInt(json['id']),
      userNip: json['user_nip']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      waktu: _parseDateTime(json['waktu']),
      latitude: _parseToDouble(json['latitude']),
      longitude: _parseToDouble(json['longitude']),
      lateDuration: _parseToInt(json['late_duration']),
      overtimeDuration: _parseToInt(json['overtime_duration']),
      createdAt: json['created_at'] != null
          ? _parseDateTime(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? _parseDateTime(json['updated_at'])
          : null,
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        try {
          // Try parsing as double first, then convert to int
          return double.parse(value).toInt();
        } catch (e2) {
          print('Error parsing int value "$value": $e2');
          return 0;
        }
      }
    }
    return 0;
  }


  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('Error parsing double value "$value": $e');
        return 0.0;
      }
    }
    return 0.0;
  }


  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing DateTime value "$value": $e');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_nip': userNip,
      'type': type,
      'waktu': waktu.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'late_duration': lateDuration,
      'overtime_duration': overtimeDuration,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AttendanceModel(id: $id, type: $type, waktu: $waktu, lat: $latitude, lng: $longitude)';
  }
}
