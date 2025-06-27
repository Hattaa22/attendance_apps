import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/leave_model.dart';

class LeaveException implements Exception {
  final String message;
  LeaveException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class LeaveService {
  static final LeaveService _instance = LeaveService._internal();
  factory LeaveService() => _instance;
  LeaveService._internal();

  final Dio _dio = ApiService().dio;

  Future<LeaveModel> applyLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? proofFilePath,
  }) async {
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

      final response = await _dio
          .post('/leave/apply', data: formData)
          .timeout(Duration(seconds: 30));

      if (response.data == null) {
        throw LeaveException('Empty response from server');
      }

      if (response.data['leave'] == null) {
        throw LeaveException('Invalid response format: missing leave data');
      }

      return LeaveModel.fromJson(response.data['leave']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.response?.statusCode == 422) {
        // Handle validation errors
        if (e.response?.data['errors'] != null) {
          final errors = e.response?.data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          final errorMessage =
              firstError is List ? firstError.first : firstError.toString();
          throw ValidationException(errorMessage);
        } else {
          throw ValidationException(
              e.response?.data['message'] ?? 'Validation failed');
        }
      } else if (e.response?.statusCode == 400) {
        throw LeaveException(e.response?.data['message'] ?? 'Bad request');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
            'Connection timeout - please check your internet connection');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
            'Unable to connect to server - please check your internet connection');
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        throw LeaveException(e.response?.data['message']);
      }

      throw LeaveException('Failed to apply leave: Network error');
    } catch (e) {
      if (e is LeaveException ||
          e is UnauthorizedException ||
          e is ValidationException ||
          e is NetworkException) {
        rethrow;
      }
      throw LeaveException('Failed to apply leave: $e');
    }
  }

  Future<List<LeaveModel>> getMyLeaves() async {
    try {
      final response =
          await _dio.get('/leave/my').timeout(Duration(seconds: 10));

      // Debug 1: Print tipe response
      print('Response type: ${response.data.runtimeType}');

      // Debug 2: Print struktur response
      print('Full response: ${response.data}');

      // Handle enveloped response
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // Debug 3: Print keys pada envelop
        print('Response keys: ${responseData.keys.join(', ')}');

        // Handle berbagai kemungkinan struktur envelop
        if (responseData['data'] != null && responseData['data'] is List) {
          final leavesData = responseData['data'] as List;
          print('Leaves data count: ${leavesData.length}');
          return leavesData.map((json) => LeaveModel.fromJson(json)).toList();
        } else if (responseData['leaves'] != null &&
            responseData['leaves'] is List) {
          final leavesData = responseData['leaves'] as List;
          print('Leaves data count: ${leavesData.length}');
          return leavesData.map((json) => LeaveModel.fromJson(json)).toList();
        }
      }
      // Handle jika response langsung array
      else if (response.data is List) {
        final leavesData = response.data as List;
        print('Direct leaves data count: ${leavesData.length}');
        return leavesData.map((json) => LeaveModel.fromJson(json)).toList();
      }

      throw LeaveException('Invalid response format');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      }

      throw LeaveException(
          e.response?.data['message'] ?? 'Failed to get leave data');
    } catch (e) {
      if (e is UnauthorizedException || e is NetworkException) {
        rethrow;
      }
      throw LeaveException('Failed to get leave data: $e');
    }
  }

  Future<List<LeaveModel>> getLeaveHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? type,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};

      if (startDate != null) {
        queryParams['start_date'] = DateFormat('yyyy-MM-dd').format(startDate);
      }
      if (endDate != null) {
        queryParams['end_date'] = DateFormat('yyyy-MM-dd').format(endDate);
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final response = await _dio
          .get('/leave/history', queryParameters: queryParams)
          .timeout(Duration(seconds: 10));

      if (response.data == null) {
        throw LeaveException('Empty response from server');
      }

      final List<dynamic> leavesData = response.data;
      return leavesData.map((json) => LeaveModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      }

      throw LeaveException(
          e.response?.data['message'] ?? 'Failed to get leave history');
    } catch (e) {
      if (e is UnauthorizedException || e is NetworkException) {
        rethrow;
      }
      throw LeaveException('Failed to get leave history: $e');
    }
  }

  Future<Map<String, dynamic>> getLeaveBalance() async {
    try {
      final response =
          await _dio.get('/leave/balance').timeout(Duration(seconds: 10));

      if (response.data == null) {
        throw LeaveException('Empty response from server');
      }

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      }

      throw LeaveException(
          e.response?.data['message'] ?? 'Failed to get leave balance');
    } catch (e) {
      if (e is UnauthorizedException || e is NetworkException) {
        rethrow;
      }
      throw LeaveException('Failed to get leave balance: $e');
    }
  }

  Future<LeaveModel> cancelLeave(int leaveId) async {
    try {
      final response = await _dio
          .post('/leave/$leaveId/cancel')
          .timeout(Duration(seconds: 10));

      if (response.data == null) {
        throw LeaveException('Empty response from server');
      }

      if (response.data['leave'] == null) {
        throw LeaveException('Invalid response format: missing leave data');
      }

      return LeaveModel.fromJson(response.data['leave']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
            e.response?.data['message'] ?? 'Unauthorized access');
      } else if (e.response?.statusCode == 404) {
        throw LeaveException('Leave not found');
      } else if (e.response?.statusCode == 400) {
        throw LeaveException(
            e.response?.data['message'] ?? 'Cannot cancel this leave');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Unable to connect to server');
      }

      throw LeaveException(
          e.response?.data['message'] ?? 'Failed to cancel leave');
    } catch (e) {
      if (e is UnauthorizedException || e is NetworkException) {
        rethrow;
      }
      throw LeaveException('Failed to cancel leave: $e');
    }
  }
}
