import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/data/repositories/attendance_repository.dart';

class AttendanceController extends GetxController {
  final AttendanceRepository _attendanceRepository = AttendanceRepositoryImpl();

  var isLoading = false.obs;
  var attendanceHistory = [].obs;
  var errorMessage = ''.obs;
  var statistics = {}.obs;

  Future<void> fetchAttendanceHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _attendanceRepository.getAttendanceHistory(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
      print('Attendance result: $result'); // Tambahkan ini
      if (result['success'] == true) {
        attendanceHistory.value = result['attendance'] ?? [];
        statistics.value = result['statistics'] ?? {};
      } else {
        errorMessage.value =
            result['message'] ?? 'Gagal mengambil data kehadiran';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
