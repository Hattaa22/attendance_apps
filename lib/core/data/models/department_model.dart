class DepartmentModel {
  final int id;
  final String department;
  final String? managerDepartment;

  DepartmentModel({
    required this.id,
    required this.department,
    this.managerDepartment,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      department: json['department'].toString(),
      managerDepartment: json['manager_department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'department': department,
      'manager_department': managerDepartment,
    };
  }

  // Helper methods
  String get displayName => department;
  String get displayManager => managerDepartment ?? 'No Manager';
  bool get hasManager =>
      managerDepartment != null && managerDepartment!.isNotEmpty;
}

class TeamDepartmentModel {
  final int id;
  final String name;

  TeamDepartmentModel({
    required this.id,
    required this.name,
  });

  factory TeamDepartmentModel.fromJson(Map<String, dynamic> json) {
    return TeamDepartmentModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  String get displayName => name;
}

class TeamUserModel {
  final String nip;
  final String name;
  final String email;

  TeamUserModel({
    required this.nip,
    required this.name,
    required this.email,
  });

  factory TeamUserModel.fromJson(Map<String, dynamic> json) {
    return TeamUserModel(
      nip: json['nip'].toString(),
      name: json['name'].toString(),
      email: json['email'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nip': nip,
      'name': name,
      'email': email,
    };
  }

  String get displayName => name;
  String get displayInfo => '$name ($nip)';
}
