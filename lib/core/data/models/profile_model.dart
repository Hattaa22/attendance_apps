class ProfileModel {
  final String nip;
  final String name;
  final String? department;
  final String? teamDepartment;
  final String? managerDepartment;

  ProfileModel({
    required this.nip,
    required this.name,
    this.department,
    this.teamDepartment,
    this.managerDepartment,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      nip: json['nip'].toString(),
      name: json['name'].toString(),
      department: json['department'],
      teamDepartment: json['team_department'],
      managerDepartment: json['manager_department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nip': nip,
      'name': name,
      'department': department,
      'team_department': teamDepartment,
      'manager_department': managerDepartment,
    };
  }

  bool get hasDepartment => department != null && department!.isNotEmpty;
  bool get hasTeamDepartment =>
      teamDepartment != null && teamDepartment!.isNotEmpty;
  bool get hasManager =>
      managerDepartment != null && managerDepartment!.isNotEmpty;

  String get displayName => name;
  String get displayDepartment => department ?? 'No Department';
  String get displayTeam => teamDepartment ?? 'No Team';
  String get displayManager => managerDepartment ?? 'No Manager';
}

class UpdateProfileRequest {
  final String name;
  final String? password;
  final String? passwordConfirmation;

  UpdateProfileRequest({
    required this.name,
    this.password,
    this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
    };

    if (password != null && password!.isNotEmpty) {
      data['password'] = password!;
      data['password_confirmation'] = passwordConfirmation ?? password!;
    }

    return data;
  }

  bool get isValid {
    if (name.trim().isEmpty) return false;
    if (password != null && password!.isNotEmpty) {
      if (password!.length < 6) return false;
      if (password != passwordConfirmation) return false;
    }
    return true;
  }

  String? get validationError {
    if (name.trim().isEmpty) return 'Name is required';
    if (password != null && password!.isNotEmpty) {
      if (password!.length < 6) return 'Password must be at least 6 characters';
      if (password != passwordConfirmation) {
        return 'Password confirmation does not match';
      }
    }
    return null;
  }
}
