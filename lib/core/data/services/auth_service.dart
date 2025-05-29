import 'package:dio/dio.dart';
import 'api_service.dart';

class AuthService {
  final Dio dio = ApiService().dio;

  Future<Map<String, dynamic>> login(String nip, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'nip': nip,
        'password': password,
      });

      return {
        'success': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data ?? e.message,
      };
    }
  }
}