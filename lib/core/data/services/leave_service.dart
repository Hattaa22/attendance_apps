import '../repositories/leave_repository.dart';
import 'auth_service.dart';

class LeaveService {
  static final LeaveService _instance = LeaveService._internal();
  factory LeaveService() => _instance;

  late LeaveRepository _repository;
  final AuthService _authService;

  LeaveService._internal() : _authService = AuthService() {
    _repository = LeaveRepositoryImpl();
  }

  // For testing
  LeaveService.withRepository(this._repository) : _authService = AuthService();

  Future<Map<String, dynamic>> applyLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? proofFilePath,
  }) async {
    try {
      if (!await _authService.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to apply for leave',
          'requiresLogin': true,
        };
      }

      if (!['paid', 'sick'].contains(type)) {
        return {
          'success': false,
          'message': 'Invalid leave type. Choose "paid" or "sick"',
        };
      }

      if (startDate.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
        return {
          'success': false,
          'message': 'Start date cannot be before today',
        };
      }

      if (endDate.isBefore(startDate)) {
        return {
          'success': false,
          'message': 'End date cannot be before start date',
        };
      }

      if (reason.trim().isEmpty || reason.length > 255) {
        return {
          'success': false,
          'message': 'Reason is required and must be less than 255 characters',
        };
      }

      final leave = await _repository.applyLeave(
        type: type,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        proofFilePath: proofFilePath,
      );

      return {
        'success': true,
        'message': 'Leave application submitted successfully',
        'leave': leave.toJson(),
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      return {
        'success': false,
        'message': errorMessage,
        'requiresLogin': _authService.isAuthError(errorMessage),
      };
    }
  }

  Future<Map<String, dynamic>> getMyLeaves() async {
    try {
      if (!await _authService.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to view leaves',
          'requiresLogin': true,
        };
      }

      final leaves = await _repository.getMyLeaves();

      return {
        'success': true,
        'leaves': leaves.map((leave) => leave.toJson()).toList(),
        'total': leaves.length,
      };
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      return {
        'success': false,
        'message': errorMessage,
        'requiresLogin': _authService.isAuthError(errorMessage),
      };
    }
  }

  Future<Map<String, dynamic>> getLeavesByStatus(String status) async {
    try {
      final result = await getMyLeaves();
      if (!result['success']) return result;

      final leaves = (result['leaves'] as List)
          .where((leave) => leave['status'] == status)
          .toList();

      return {
        'success': true,
        'leaves': leaves,
        'total': leaves.length,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  // region - statistics
  Future<Map<String, dynamic>> getPendingLeaves() async {
    return await getLeavesByStatus('pending');
  }

  Future<Map<String, dynamic>> getApprovedLeaves() async {
    return await getLeavesByStatus('approved');
  }

  Future<Map<String, dynamic>> getRejectedLeaves() async {
    return await getLeavesByStatus('rejected');
  }

  Future<Map<String, dynamic>> getLeaveStatistics() async {
    try {
      final result = await getMyLeaves();
      if (!result['success']) return result;

      final leaves = result['leaves'] as List;

      final pending =
          leaves.where((leave) => leave['status'] == 'pending').length;
      final approved =
          leaves.where((leave) => leave['status'] == 'approved').length;
      final rejected =
          leaves.where((leave) => leave['status'] == 'rejected').length;

      final paidLeaves =
          leaves.where((leave) => leave['type'] == 'paid').length;
      final sickLeaves =
          leaves.where((leave) => leave['type'] == 'sick').length;

      return {
        'success': true,
        'statistics': {
          'total': leaves.length,
          'pending': pending,
          'approved': approved,
          'rejected': rejected,
          'paid_leaves': paidLeaves,
          'sick_leaves': sickLeaves,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }
}
