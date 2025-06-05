import '../repositories/leave_repository.dart';

class LeaveService {
  static final LeaveService _instance = LeaveService._internal();
  factory LeaveService() => _instance;

  late LeaveRepository _repository;

  LeaveService._internal() {
    _repository = LeaveRepositoryImpl();
  }

  // For testing
  LeaveService.withRepository(this._repository);

  Future<Map<String, dynamic>> applyLeave({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? proofFilePath,
  }) async {
    try {
      // region - validation

      // Validate leave type
      if (!['paid', 'sick'].contains(type)) {
        return {
          'success': false,
          'message': 'Tipe cuti tidak valid. Pilih "paid" atau "sick"',
        };
      }

      // Validate dates
      if (startDate.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
        return {
          'success': false,
          'message': 'Tanggal mulai tidak boleh kurang dari hari ini',
        };
      }

      if (endDate.isBefore(startDate)) {
        return {
          'success': false,
          'message': 'Tanggal selesai tidak boleh kurang dari tanggal mulai',
        };
      }

      // Validate reason
      if (reason.trim().isEmpty || reason.length > 255) {
        return {
          'success': false,
          'message': 'Alasan cuti harus diisi dan maksimal 255 karakter',
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
        'message': 'Pengajuan cuti berhasil dikirim',
        'leave': leave.toJson(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }
  // endregion

  Future<Map<String, dynamic>> getMyLeaves() async {
    try {
      final leaves = await _repository.getMyLeaves();

      return {
        'success': true,
        'leaves': leaves.map((leave) => leave.toJson()).toList(),
        'total': leaves.length,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
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
