class UserModel {
  final String nip;
  final String name;
  final String email;
  final int? roleId;
  final int? teamDepartmentId;

  UserModel({
    required this.nip,
    required this.name,
    required this.email,
    this.roleId,
    this.teamDepartmentId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nip: json['nip'],
      name: json['name'],
      email: json['email'],
      roleId: json['role_id'],
      teamDepartmentId: json['team_department_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nip': nip,
      'name': name,
      'email': email,
      'role_id': roleId,
      'team_department_id': teamDepartmentId,
    };
  }
}

class LoginResponse {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;
  final String tokenType;
  final int? expiresIn;

  LoginResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
    this.tokenType = 'Bearer',
    this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: UserModel.fromJson(json['user']),
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}
