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

  // Helper methods
  String get displayName => name;
  String get displayInfo => '$name ($nip)';
  bool get hasRole => roleId != null;
  bool get hasTeamDepartment => teamDepartmentId != null;
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
    final user = UserModel.fromJson(json['user']);
    
    return LoginResponse(
      accessToken: json['access_token'].toString(),
      refreshToken: json['refresh_token']?.toString(),
      user: user,
      tokenType: json['token_type']?.toString() ?? 'bearer',
      expiresIn: json['expires_in'] is int 
          ? json['expires_in'] 
          : int.tryParse(json['expires_in'].toString()),
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

  bool get hasRefreshToken => refreshToken != null && refreshToken!.isNotEmpty;
  bool get hasExpiryTime => expiresIn != null;
  
  DateTime? get expiryDateTime {
    if (expiresIn == null) return null;
    return DateTime.now().add(Duration(seconds: expiresIn!));
  }

  bool get isExpired {
    final expiry = expiryDateTime;
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry);
  }

  Duration? get timeUntilExpiry {
    final expiry = expiryDateTime;
    if (expiry == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiry)) return Duration.zero;
    return expiry.difference(now);
  }
}
