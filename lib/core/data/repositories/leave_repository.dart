import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/leave_model.dart';

abstract class LeaveRepository {
  Future<LeaveModel> applyLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? proofFilePath,
  });

  Future<List<LeaveModel>> getMyLeaves();
}

class LeaveRepositoryImpl implements LeaveRepository {
  final Dio _dio;
  final AuthService _authService;

  LeaveRepositoryImpl() : _dio = ApiService().dio, _authService = AuthService();

  @override
  Future<LeaveModel> applyLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? proofFilePath,
  }) async {
    await _authService.requireAuthentication();

    try {
      FormData formData = FormData.fromMap({
        'type': type,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate),
        'reason': reason,
      });

      if (proofFilePath != null) {
        formData.files.add(MapEntry(
          'proof_file',
          await MultipartFile.fromFile(proofFilePath),
        ));
      }

      final response = await _dio.post('/leave/apply', data: formData);
      final leave = LeaveModel.fromJson(response.data['leave']);
      return leave;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _authService.handle401();
      }

      if (e.response?.statusCode == 422 && e.response?.data['errors'] != null) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        final errorMessage = firstError is List ? firstError.first : firstError;
        throw Exception(errorMessage);
      }

      throw Exception(e.response?.data['message'] ?? 'Failed to apply leave');
    } catch (e) {
      if (e.toString().contains('User not authenticated')) {
        rethrow;
      }
      throw Exception('Failed to apply leave: $e');
    }
  }

  @override
  Future<List<LeaveModel>> getMyLeaves() async {
    await _authService.requireAuthentication();

    try {
      final response = await _dio.get('/leave/my');
      final List<dynamic> leavesData = response.data;
      final leaves =
          leavesData.map((json) => LeaveModel.fromJson(json)).toList();

      return leaves;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _authService.handle401();
      }

      throw Exception(
          e.response?.data['message'] ?? 'Failed to get leave data');
    } catch (e) {
      if (e.toString().contains('User not authenticated')) {
        rethrow;
      }
      throw Exception('Failed to get leave data: $e');
    }
  }
}
