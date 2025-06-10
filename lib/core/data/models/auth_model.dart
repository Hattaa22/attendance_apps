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
      nip: json['nip'].toString(),
      name: json['name'].toString(),
      email: json['email'].toString(),

      // I dont know why but i have to parse these as int when in the production environment
      roleId: json['role_id'] != null ? int.tryParse(json['role_id'].toString()) : null,
      teamDepartmentId: json['team_department_id'] != null ? int.tryParse(json['team_department_id'].toString()) : null,
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
  print('DEBUG: Starting LoginResponse parsing...');
  print('DEBUG: access_token type: ${json['access_token'].runtimeType}');
  print('DEBUG: expires_in: ${json['expires_in']} (${json['expires_in'].runtimeType})');
  print('DEBUG: user data: ${json['user']}');
  
  final user = UserModel.fromJson(json['user']);
  print('DEBUG: User parsed successfully');
  
  return LoginResponse(
    accessToken: json['access_token'],
    refreshToken: json['refresh_token'],
    user: user,
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
