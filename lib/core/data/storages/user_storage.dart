import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class UserStorage {
  static const _key = 'user_data';
  static final _storage = FlutterSecureStorage();

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final json = jsonEncode(user);
    await _storage.write(key: _key, value: json);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final json = await _storage.read(key: _key);
    if (json == null) return null;
    return jsonDecode(json);
  }

  static Future<void> clearUser() async {
    await _storage.delete(key: _key);
  }
}