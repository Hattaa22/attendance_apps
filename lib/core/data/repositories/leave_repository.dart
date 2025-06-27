import 'package:intl/intl.dart';
import '../services/auth_service.dart'
    show UnauthorizedException, NetworkException;
import '../models/leave_model.dart';
import '../services/leave_service.dart'
    show LeaveException, LeaveService, ValidationException;
import '../repositories/auth_repository.dart';

abstract class LeaveRepository {
  Future<Map<String, dynamic>> applyLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? proofFilePath,
  });

  Future<Map<String, dynamic>> getMyLeaves();
  Future<Map<String, dynamic>> getLeaveHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? type,
  });
  Future<Map<String, dynamic>> getLeavesByStatus(String status);
  Future<Map<String, dynamic>> getPendingLeaves();
  Future<Map<String, dynamic>> getApprovedLeaves();
  Future<Map<String, dynamic>> getRejectedLeaves();
  Future<Map<String, dynamic>> getLeaveStatistics();
  Future<Map<String, dynamic>> getLeaveBalance();
  Future<Map<String, dynamic>> cancelLeave(int leaveId);
  Future<Map<String, dynamic>> validateLeaveApplication({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? proofFilePath,
  });
  String formatLeaveStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown Status';
    }
  }

  String formatLeaveType(String type) {
    switch (type.toLowerCase()) {
      case 'paid':
        return 'Paid Leave';
      case 'sick':
        return 'Sick Leave';
      case 'emergency':
        return 'Emergency Leave';
      case 'maternity':
        return 'Maternity Leave';
      case 'paternity':
        return 'Paternity Leave';
      default:
        return 'Unknown Type';
    }
  }

  String formatLeaveDuration(int days) {
    if (days == 1) {
      return '1 day';
    } else if (days < 30) {
      return '$days days';
    } else {
      final weeks = days ~/ 7;
      final remainingDays = days % 7;
      return '$weeks week${weeks > 1 ? 's' : ''} ${remainingDays > 0 ? '$remainingDays day${remainingDays > 1 ? 's' : ''}' : ''}';
    }
  }
}

class LeaveRepositoryImpl implements LeaveRepository {
  final LeaveService _service = LeaveService();
  final AuthRepository _authRepository = AuthRepositoryImpl();

  @override
  Future<Map<String, dynamic>> applyLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? proofFilePath,
  }) async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to apply for leave',
          'requiresLogin': true,
        };
      }

      final validation = _validateLeaveApplication(
        type: type,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        proofFilePath: proofFilePath,
      );

      if (!validation['valid']) {
        return {
          'success': false,
          'message': validation['message'],
          'type': 'validation',
        };
      }

      final overlappingCheck =
          await _checkOverlappingLeaves(startDate, endDate);
      if (!overlappingCheck['success']) {
        return overlappingCheck;
      }

      final balanceCheck = await _checkLeaveBalance(type, startDate, endDate);
      if (!balanceCheck['success']) {
        return balanceCheck;
      }

      final leave = await _service.applyLeave(
        type: type,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        proofFilePath: proofFilePath,
      );

      final duration = _calculateLeaveDuration(startDate, endDate);

      return {
        'success': true,
        'message': 'Leave application submitted successfully',
        'leave': leave.toJson(),
        'duration': duration,
        'submission_date': DateTime.now().toIso8601String(),
      };
    } on UnauthorizedException catch (e) {
      await _authRepository.handle401();
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': true,
        'sessionExpired': true,
      };
    } on ValidationException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'validation',
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on LeaveException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'leave',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred while applying for leave',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getMyLeaves() async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to view your leaves',
          'requiresLogin': true,
        };
      }

      final leaves = await _service.getMyLeaves();

      // Handle empty response
      if (leaves.isEmpty) {
        return {
          'success': true,
          'message': 'No leave data available',
          'leaves': [],
          'total': 0,
        };
      }

      return {
        'success': true,
        'leaves': leaves.map((leave) => leave.toJson()).toList(),
        'total': leaves.length,
      };
    } on UnauthorizedException catch (e) {
      await _authRepository.handle401();
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': true,
        'sessionExpired': true,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on LeaveException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'leave',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to retrieve leave data',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getLeaveHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? type,
  }) async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to view leave history',
          'requiresLogin': true,
        };
      }

      if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
        return {
          'success': false,
          'message': 'Start date cannot be after end date',
          'type': 'validation',
        };
      }

      final leaves = await _service.getLeaveHistory(
        startDate: startDate,
        endDate: endDate,
        status: status,
        type: type,
      );

      final statistics = _calculateLeaveStatistics(leaves);

      return {
        'success': true,
        'leaves': leaves.map((leave) => leave.toJson()).toList(),
        'total': leaves.length,
        'statistics': statistics,
        'filters': {
          'start_date': startDate?.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
          'status': status,
          'type': type,
        },
        'message': 'Leave history retrieved successfully',
      };
    } on UnauthorizedException catch (e) {
      await _authRepository.handle401();
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': true,
        'sessionExpired': true,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on LeaveException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'leave',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to retrieve leave history',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getLeavesByStatus(String status) async {
    try {
      if (!_isValidLeaveStatus(status)) {
        return {
          'success': false,
          'message': 'Invalid leave status: $status',
          'type': 'validation',
        };
      }

      return await getLeaveHistory(status: status);
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get leaves by status',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getPendingLeaves() async {
    return await getLeavesByStatus('pending');
  }

  @override
  Future<Map<String, dynamic>> getApprovedLeaves() async {
    return await getLeavesByStatus('approved');
  }

  @override
  Future<Map<String, dynamic>> getRejectedLeaves() async {
    return await getLeavesByStatus('rejected');
  }

  @override
  Future<Map<String, dynamic>> getLeaveStatistics() async {
    try {
      final result = await getMyLeaves();
      if (!result['success']) return result;

      final leaves = result['leaves'] as List;

      final stats = _calculateComprehensiveStatistics(leaves);

      return {
        'success': true,
        'statistics': stats,
        'message': 'Leave statistics calculated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to calculate leave statistics',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getLeaveBalance() async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to view leave balance',
          'requiresLogin': true,
        };
      }

      final balance = await _service.getLeaveBalance();

      final processedBalance = _processLeaveBalance(balance);

      return {
        'success': true,
        'balance': processedBalance,
        'message': 'Leave balance retrieved successfully',
      };
    } on UnauthorizedException catch (e) {
      await _authRepository.handle401();
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': true,
        'sessionExpired': true,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on LeaveException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'leave',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to retrieve leave balance',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> cancelLeave(int leaveId) async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to cancel leave',
          'requiresLogin': true,
        };
      }

      if (leaveId <= 0) {
        return {
          'success': false,
          'message': 'Invalid leave ID',
          'type': 'validation',
        };
      }

      final canCancelCheck = await _checkIfLeaveCanBeCancelled(leaveId);
      if (!canCancelCheck['success']) {
        return canCancelCheck;
      }

      final cancelledLeave = await _service.cancelLeave(leaveId);

      return {
        'success': true,
        'message': 'Leave cancelled successfully',
        'leave': cancelledLeave.toJson(),
        'cancelled_at': DateTime.now().toIso8601String(),
      };
    } on UnauthorizedException catch (e) {
      await _authRepository.handle401();
      return {
        'success': false,
        'message': e.message,
        'requiresLogin': true,
        'sessionExpired': true,
      };
    } on NetworkException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'network',
        'retryable': true,
      };
    } on LeaveException catch (e) {
      return {
        'success': false,
        'message': e.message,
        'type': 'leave',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to cancel leave',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  @override
  Future<Map<String, dynamic>> validateLeaveApplication({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? proofFilePath,
  }) async {
    try {
      if (!await _authRepository.isAuthenticated()) {
        return {
          'success': false,
          'message': 'Please login to validate leave application',
          'requiresLogin': true,
        };
      }

      final validation = _validateLeaveApplication(
        type: type,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        proofFilePath: proofFilePath,
      );

      if (!validation['valid']) {
        return {
          'success': false,
          'message': validation['message'],
          'type': 'validation',
          'field': validation['field'],
        };
      }

      final overlappingCheck =
          await _checkOverlappingLeaves(startDate, endDate);
      if (!overlappingCheck['success']) {
        return overlappingCheck;
      }

      final balanceCheck = await _checkLeaveBalance(type, startDate, endDate);
      if (!balanceCheck['success']) {
        return balanceCheck;
      }

      final duration = _calculateLeaveDuration(startDate, endDate);

      return {
        'success': true,
        'message': 'Leave application is valid',
        'validation': {
          'type': type,
          'duration': duration,
          'working_days': duration['working_days'],
          'starts_in_days': startDate.difference(DateTime.now()).inDays,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to validate leave application',
        'type': 'unknown',
        'details': e.toString(),
      };
    }
  }

  Map<String, dynamic> _validateLeaveApplication({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? proofFilePath,
  }) {
    if (!['paid', 'sick', 'emergency', 'maternity', 'paternity']
        .contains(type)) {
      return {
        'valid': false,
        'message':
            'Invalid leave type. Choose: paid, sick, emergency, maternity, or paternity',
        'field': 'type',
      };
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final startDateOnly =
        DateTime(startDate.year, startDate.month, startDate.day);

    if (startDateOnly.isBefore(todayOnly)) {
      return {
        'valid': false,
        'message': 'Start date cannot be before today',
        'field': 'start_date',
      };
    }

    if (endDate.isBefore(startDate)) {
      return {
        'valid': false,
        'message': 'End date cannot be before start date',
        'field': 'end_date',
      };
    }

    final duration = endDate.difference(startDate).inDays + 1;
    if ((type == 'paid' || type == 'sick') && duration > 30) {
      return {
        'valid': false,
        'message': 'Leave duration cannot exceed 30 days for $type leave',
        'field': 'duration',
      };
    }

    if (reason.trim().isEmpty) {
      return {
        'valid': false,
        'message': 'Reason is required',
        'field': 'reason',
      };
    }

    if (reason.length > 500) {
      return {
        'valid': false,
        'message': 'Reason must be less than 500 characters',
        'field': 'reason',
      };
    }

    if (type == 'sick' &&
        duration > 3 &&
        (proofFilePath == null || proofFilePath.isEmpty)) {
      return {
        'valid': false,
        'message':
            'Medical certificate is required for sick leave longer than 3 days',
        'field': 'proof_file',
      };
    }

    return {
      'valid': true,
      'message': 'Leave application data is valid',
    };
  }

  Future<Map<String, dynamic>> _checkOverlappingLeaves(
      DateTime startDate, DateTime endDate) async {
    try {
      final pendingResult = await getPendingLeaves();
      final approvedResult = await getApprovedLeaves();

      List<dynamic> existingLeaves = [];
      if (pendingResult['success']) {
        existingLeaves.addAll(pendingResult['leaves']);
      }
      if (approvedResult['success']) {
        existingLeaves.addAll(approvedResult['leaves']);
      }

      for (var leave in existingLeaves) {
        final leaveStart = DateTime.parse(leave['start_date']);
        final leaveEnd = DateTime.parse(leave['end_date']);

        if ((startDate.isBefore(leaveEnd) ||
                startDate.isAtSameMomentAs(leaveEnd)) &&
            (endDate.isAfter(leaveStart) ||
                endDate.isAtSameMomentAs(leaveStart))) {
          return {
            'success': false,
            'message':
                'Leave dates overlap with existing leave (${leave['type']} leave from ${DateFormat('MMM dd').format(leaveStart)} to ${DateFormat('MMM dd').format(leaveEnd)})',
            'type': 'overlap',
            'overlapping_leave': leave,
          };
        }
      }

      return {'success': true};
    } catch (e) {
      return {
        'success': true,
        'warning': 'Could not check for overlapping leaves'
      };
    }
  }

  Future<Map<String, dynamic>> _checkLeaveBalance(
      String type, DateTime startDate, DateTime endDate) async {
    try {
      final balanceResult = await getLeaveBalance();
      if (!balanceResult['success']) {
        return {'success': true, 'warning': 'Could not check leave balance'};
      }

      final balance = balanceResult['balance'];
      final requestedDays =
          _calculateLeaveDuration(startDate, endDate)['working_days'];

      int availableDays = 0;
      String balanceField = '';

      switch (type) {
        case 'paid':
          availableDays = balance['paid_leave_balance'] ?? 0;
          balanceField = 'paid leave';
          break;
        case 'sick':
          availableDays = balance['sick_leave_balance'] ?? 0;
          balanceField = 'sick leave';
          break;
        default:
          return {'success': true};
      }

      if (requestedDays > availableDays) {
        return {
          'success': false,
          'message':
              'Insufficient $balanceField balance. Requested: $requestedDays days, Available: $availableDays days',
          'type': 'insufficient_balance',
          'requested_days': requestedDays,
          'available_days': availableDays,
        };
      }

      return {'success': true};
    } catch (e) {
      return {'success': true, 'warning': 'Could not verify leave balance'};
    }
  }

  Future<Map<String, dynamic>> _checkIfLeaveCanBeCancelled(int leaveId) async {
    try {
      final leavesResult = await getMyLeaves();
      if (!leavesResult['success']) {
        return {
          'success': false,
          'message': 'Cannot verify leave status',
          'type': 'verification_failed',
        };
      }

      final leaves = leavesResult['leaves'] as List;
      final leave = leaves.where((l) => l['id'] == leaveId).firstOrNull;

      if (leave == null) {
        return {
          'success': false,
          'message': 'Leave not found',
          'type': 'not_found',
        };
      }

      if (leave['status'] != 'pending') {
        return {
          'success': false,
          'message': 'Only pending leaves can be cancelled',
          'type': 'invalid_status',
          'current_status': leave['status'],
        };
      }

      final startDate = DateTime.parse(leave['start_date']);
      if (startDate.isBefore(DateTime.now()) ||
          startDate.isAtSameMomentAs(DateTime.now())) {
        return {
          'success': false,
          'message': 'Cannot cancel leave that has already started',
          'type': 'already_started',
        };
      }

      return {'success': true};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to verify if leave can be cancelled',
        'type': 'verification_error',
        'details': e.toString(),
      };
    }
  }

  Map<String, dynamic> _calculateLeaveDuration(
      DateTime startDate, DateTime endDate) {
    final totalDays = endDate.difference(startDate).inDays + 1;

    int workingDays = 0;
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      if (currentDate.weekday != DateTime.saturday &&
          currentDate.weekday != DateTime.sunday) {
        workingDays++;
      }
      currentDate = currentDate.add(Duration(days: 1));
    }

    return {
      'total_days': totalDays,
      'working_days': workingDays,
      'weekend_days': totalDays - workingDays,
      'start_date': DateFormat('yyyy-MM-dd').format(startDate),
      'end_date': DateFormat('yyyy-MM-dd').format(endDate),
    };
  }

  Map<String, dynamic> _processLeaveData(List<LeaveModel> leaves) {
    final leaveData = leaves.map((l) => l.toJson()).toList();

    leaveData.sort((a, b) => DateTime.parse(b['created_at'] ?? b['start_date'])
        .compareTo(DateTime.parse(a['created_at'] ?? a['start_date'])));

    final summary = _calculateLeaveStatistics(leaves);
    final recent = leaveData.take(5).toList();

    return {
      'summary': summary,
      'recent': recent,
    };
  }

  Map<String, dynamic> _calculateLeaveStatistics(List<LeaveModel> leaves) {
    final leaveData = leaves.map((l) => l.toJson()).toList();

    final pending = leaveData.where((l) => l['status'] == 'pending').length;
    final approved = leaveData.where((l) => l['status'] == 'approved').length;
    final rejected = leaveData.where((l) => l['status'] == 'rejected').length;

    final paidLeaves = leaveData.where((l) => l['type'] == 'paid').length;
    final sickLeaves = leaveData.where((l) => l['type'] == 'sick').length;
    final emergencyLeaves =
        leaveData.where((l) => l['type'] == 'emergency').length;

    return {
      'total': leaves.length,
      'by_status': {
        'pending': pending,
        'approved': approved,
        'rejected': rejected,
      },
      'by_type': {
        'paid': paidLeaves,
        'sick': sickLeaves,
        'emergency': emergencyLeaves,
      },
    };
  }

  Map<String, dynamic> _calculateComprehensiveStatistics(List<dynamic> leaves) {
    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;

    final thisYearLeaves = leaves.where((leave) {
      final startDate = DateTime.parse(leave['start_date']);
      return startDate.year == currentYear;
    }).toList();

    final thisMonthLeaves = leaves.where((leave) {
      final startDate = DateTime.parse(leave['start_date']);
      return startDate.year == currentYear && startDate.month == currentMonth;
    }).toList();

    final basicStats = _calculateLeaveStatistics(
        leaves.map((l) => LeaveModel.fromJson(l)).toList());

    return {
      ...basicStats,
      'this_year': {
        'total': thisYearLeaves.length,
        'by_type': _calculateTypeStats(thisYearLeaves),
        'by_status': _calculateStatusStats(thisYearLeaves),
      },
      'this_month': {
        'total': thisMonthLeaves.length,
        'by_type': _calculateTypeStats(thisMonthLeaves),
        'by_status': _calculateStatusStats(thisMonthLeaves),
      },
    };
  }

  Map<String, int> _calculateTypeStats(List<dynamic> leaves) {
    return {
      'paid': leaves.where((l) => l['type'] == 'paid').length,
      'sick': leaves.where((l) => l['type'] == 'sick').length,
      'emergency': leaves.where((l) => l['type'] == 'emergency').length,
      'maternity': leaves.where((l) => l['type'] == 'maternity').length,
      'paternity': leaves.where((l) => l['type'] == 'paternity').length,
    };
  }

  Map<String, int> _calculateStatusStats(List<dynamic> leaves) {
    return {
      'pending': leaves.where((l) => l['status'] == 'pending').length,
      'approved': leaves.where((l) => l['status'] == 'approved').length,
      'rejected': leaves.where((l) => l['status'] == 'rejected').length,
      'cancelled': leaves.where((l) => l['status'] == 'cancelled').length,
    };
  }

  Map<String, dynamic> _processLeaveBalance(Map<String, dynamic> balance) {
    return {
      ...balance,
      'total_available': (balance['paid_leave_balance'] ?? 0) +
          (balance['sick_leave_balance'] ?? 0),
      'usage_percentage': _calculateUsagePercentage(balance),
    };
  }

  double _calculateUsagePercentage(Map<String, dynamic> balance) {
    final totalAllowed =
        (balance['total_paid_leave'] ?? 0) + (balance['total_sick_leave'] ?? 0);
    final totalUsed =
        (balance['used_paid_leave'] ?? 0) + (balance['used_sick_leave'] ?? 0);

    if (totalAllowed == 0) return 0.0;
    return (totalUsed / totalAllowed) * 100;
  }

  bool _isValidLeaveStatus(String status) {
    return ['pending', 'approved', 'rejected', 'cancelled'].contains(status);
  }

  bool _isValidLeaveType(String type) {
    return ['paid', 'sick', 'emergency', 'maternity', 'paternity']
        .contains(type);
  }

  bool _isValidDateRange(DateTime startDate, DateTime endDate) {
    return !startDate.isAfter(endDate);
  }

  bool _isValidReason(String reason) {
    return reason.trim().isNotEmpty && reason.length <= 500;
  }

  String formatLeaveDuration(int days) {
    if (days == 1) return '1 day';
    return '$days days';
  }

  String formatLeaveStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending Approval';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String formatLeaveType(String type) {
    switch (type.toLowerCase()) {
      case 'paid':
        return 'Paid Leave';
      case 'sick':
        return 'Sick Leave';
      case 'emergency':
        return 'Emergency Leave';
      case 'maternity':
        return 'Maternity Leave';
      case 'paternity':
        return 'Paternity Leave';
      default:
        return type;
    }
  }
}
