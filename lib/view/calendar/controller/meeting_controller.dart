import 'package:get/get.dart';
import '../../../core/data/models/meeting_model.dart';
import '../../../core/data/repositories/department_repository.dart';

class MeetingController extends GetxController {
  final DepartmentRepository _departmentRepository = DepartmentRepositoryImpl();
  final RxList<MeetingModel> meetings = <MeetingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMeetings();
  }

  Future<void> loadMeetings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _departmentRepository.getMeetingList();

      if (result['success']) {
        final meetingData = result['meeting'];
        meetings.assignAll((meetingData as List)
            .map((data) => MeetingModel.fromJson(data))
            .toList());
      } else {
        errorMessage.value = result['message'] ?? 'Failed to load meetings';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred while loading meetings';
    } finally {
      isLoading.value = false;
    }
  }
}