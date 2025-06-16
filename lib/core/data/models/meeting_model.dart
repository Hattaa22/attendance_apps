class MeetingModel {
  final int? id;
  final String createdByNip;
  final String title;
  final String? description;
  final String type;
  final String? onlineUrl;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MeetingModel({
    this.id,
    required this.createdByNip,
    required this.title,
    this.description,
    required this.type,
    this.onlineUrl,
    required this.startTime,
    required this.endTime,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      createdByNip: json['created_by_nip'].toString(),
      title: json['title'].toString(),
      description: json['description'],
      type: json['type'].toString(),
      onlineUrl: json['online_url'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      location: json['location'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'created_by_nip': createdByNip,
      'title': title,
      'description': description,
      'type': type,
      'online_url': onlineUrl,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Helper methods
  bool get isOnline => type == 'online';
  bool get isOffline => type == 'offline';
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get hasUrl => onlineUrl != null && onlineUrl!.isNotEmpty;
  bool get hasLocation => location != null && location!.isNotEmpty;

  String get displayType => isOnline ? 'Online' : 'Offline';
  String get displayDateTime =>
      '${_formatDateTime(startTime)} - ${_formatDateTime(endTime)}';

  Duration get duration => endTime.difference(startTime);
  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isOngoing =>
      DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isPast => endTime.isBefore(DateTime.now());

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class CreateMeetingRequest {
  final String title;
  final String type;
  final int departmentId;
  final List<int> teamDepartmentIds;
  final List<String> userNips;
  final DateTime startTime;
  final DateTime endTime;
  final String? onlineUrl;
  final String? description;
  final String? location;

  CreateMeetingRequest({
    required this.title,
    required this.type,
    required this.departmentId,
    required this.teamDepartmentIds,
    required this.userNips,
    required this.startTime,
    required this.endTime,
    this.onlineUrl,
    this.description,
    this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'department_id': departmentId,
      'team_department_ids': teamDepartmentIds,
      'user_nips': userNips,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      if (onlineUrl != null) 'online_url': onlineUrl,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
    };
  }

  // Validation helper
  bool get isValid {
    if (title.trim().isEmpty) return false;
    if (!['online', 'offline'].contains(type)) return false;
    if (departmentId <= 0) return false;
    if (teamDepartmentIds.isEmpty) return false;
    if (userNips.isEmpty) return false;
    if (endTime.isBefore(startTime)) return false;
    if (type == 'online' && (onlineUrl == null || onlineUrl!.trim().isEmpty))
      return false;
    if (type == 'offline' && (location == null || location!.trim().isEmpty))
      return false;
    return true;
  }

  String? get validationError {
    if (title.trim().isEmpty) return 'Title is required';
    if (!['online', 'offline'].contains(type))
      return 'Type must be online or offline';
    if (departmentId <= 0) return 'Department is required';
    if (teamDepartmentIds.isEmpty) return 'At least one team is required';
    if (userNips.isEmpty) return 'At least one user is required';
    if (endTime.isBefore(startTime)) return 'End time must be after start time';
    if (type == 'online' && (onlineUrl == null || onlineUrl!.trim().isEmpty)) {
      return 'Online URL is required for online meetings';
    }
    if (type == 'offline' && (location == null || location!.trim().isEmpty)) {
      return 'Location is required for offline meetings';
    }
    return null;
  }
}

class MeetingResponse {
  final MeetingModel meeting;
  final String? headDepartment;
  final String message;

  MeetingResponse({
    required this.meeting,
    this.headDepartment,
    required this.message,
  });

  factory MeetingResponse.fromJson(Map<String, dynamic> json) {
    return MeetingResponse(
      meeting: MeetingModel.fromJson(json['meeting']),
      headDepartment: json['head_department'],
      message: json['message'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meeting': meeting.toJson(),
      'head_department': headDepartment,
      'message': message,
    };
  }
}
