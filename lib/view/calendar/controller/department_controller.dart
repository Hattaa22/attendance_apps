import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/data/repositories/department_repository.dart';
import '../../../../core/data/models/department_model.dart';

class DepartmentController extends GetxController {
  final DepartmentRepository _departmentRepository = DepartmentRepositoryImpl();

  // State variables
  var isLoading = false.obs;
  var error = RxnString();
  var departments = <DepartmentModel>[].obs;
  var teamDepartments = <TeamDepartmentModel>[].obs;
  var teamUsers = <TeamUserModel>[].obs;

  // Selected values
  var selectedDepartment = Rxn<DepartmentModel>();
  var selectedTeams = <TeamDepartmentModel>[].obs;
  var selectedUsers = <TeamUserModel>[].obs;

  // Load departments
  Future<void> loadDepartments() async {
    isLoading.value = true;
    error.value = null;

    try {
      final result = await _departmentRepository.getDepartments();
      if (result['success']) {
        departments.value = (result['departments'] as List)
            .map((dept) => DepartmentModel.fromJson(dept))
            .toList();
      } else {
        error.value = result['message'];
      }
    } catch (e) {
      error.value = 'Failed to load departments: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTeamDepartments(int departmentId) async {
    isLoading.value = true;
    error.value = null;

    try {
      final result =
          await _departmentRepository.getTeamDepartments(departmentId);
      if (result['success']) {
        teamDepartments.value = (result['teams'] as List)
            .map((team) => TeamDepartmentModel.fromJson(team))
            .toList();
      } else {
        error.value = result['message'];
      }
    } catch (e) {
      error.value = 'Failed to load team departments: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTeamUsers(List<int> teamIds) async {
    isLoading.value = true;
    error.value = null;

    try {
      final result = await _departmentRepository.getUsersFromTeams(teamIds);
      if (result['success']) {
        teamUsers.value = (result['users'] as List)
            .map((user) => TeamUserModel.fromJson(user))
            .toList();
      } else {
        error.value = result['message'];
      }
    } catch (e) {
      error.value = 'Failed to load team users: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> createMeeting({
    required String title,
    required String type,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? description,
    String? onlineUrl,
    String? location,
  }) async {
    isLoading.value = true;
    error.value = null;

    try {
      // Gabungkan tanggal dan waktu
      final startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );
      final endDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      );

      // Debug print semua inputan
      debugPrint('Title: $title');
      debugPrint('Type: $type');
      debugPrint('Department ID: ${selectedDepartment.value?.id}');
      debugPrint('Team IDs: ${selectedTeams.map((t) => t.id).toList()}');
      debugPrint('User NIPs: ${selectedUsers.map((u) => u.nip).toList()}');
      debugPrint('Start DateTime: $startDateTime');
      debugPrint('End DateTime: $endDateTime');
      debugPrint('Description: $description');
      debugPrint('Online URL: $onlineUrl');
      debugPrint('Location: $location');

      // Panggil repository
      final result = await _departmentRepository.createMeeting(
        title: title,
        type: type,
        departmentId: selectedDepartment.value!.id,
        teamDepartmentIds: selectedTeams.map((t) => t.id).toList(),
        userNips: selectedUsers.map((u) => u.nip).toList(),
        startTime: startDateTime,
        endTime: endDateTime,
        onlineUrl: type == 'online' ? onlineUrl : null,
        description: description,
        location: type == 'offline' ? location : null,
      );
      return result;
    } catch (e) {
      error.value = 'Failed to create meeting: $e';
      return {'success': false, 'message': error.value};
    } finally {
      isLoading.value = false;
    }
  }

  void selectDepartment(DepartmentModel department) {
    selectedDepartment.value = department;
    teamDepartments.clear();
    teamUsers.clear();
    loadTeamDepartments(department.id);
  }

  void selectTeams(List<TeamDepartmentModel> teams) {
    selectedTeams.assignAll(teams);
    loadTeamUsers(teams.map((t) => t.id).toList());
  }

  void selectUsers(List<TeamUserModel> users) {
    selectedUsers.value = users;
  }

  void clearSelections() {
    selectedDepartment.value = null;
    selectedTeams.clear();
    selectedUsers.clear();
  }

  bool isValidSelection() {
    return selectedDepartment.value != null &&
        selectedTeams.isNotEmpty &&
        selectedUsers.length <= 3;
  }

  @override
  void onClose() {
    clearSelections();
    super.onClose();
  }
}