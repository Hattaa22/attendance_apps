import 'package:flutter/material.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:fortis_apps/widget_global/show_dialog_success/dialog_success.dart';
import '../../../widget_global/custom_button/custom_button.dart';
import '../../../widget_global/dropdown_form_field/dropdown_form_field.dart';
import '../../../widget_global/form_field_one/form_field_one.dart';
import '../widget/multi_select.dart';
import '../widget/custom_calendar.dart';
import '../model/event_data.dart';
import 'package:get/get.dart';
import '../controller/department_controller.dart';

class AddMeetingPage extends StatefulWidget {
  const AddMeetingPage({super.key});

  @override
  State<AddMeetingPage> createState() => _AddMeetingPageState();
}

class _AddMeetingPageState extends State<AddMeetingPage> {
  final DepartmentController _departmentController =
      Get.put(DepartmentController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<String> _selectedTeamMembers = [];
  DateTime? _selectedDate;
  String? _selectedType;
  String? _selectedDepartment;
  List<String> _selectedTeamDepartment = [];
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    _departmentController.loadDepartments();
  }

  void _onFormChanged() {
    setState(() {});
  }

  bool _isFormValid() {
    bool baseValidation = _titleController.text.isNotEmpty &&
        _selectedType != null &&
        _selectedDepartment != null &&
        _selectedTeamDepartment.isNotEmpty &&
        _selectedTeamMembers.length == 3 &&
        _selectedDate != null &&
        _startTime != null &&
        _endTime != null;

    if (_selectedType == 'Online') {
      return baseValidation && _descriptionController.text.isNotEmpty;
    }

    return baseValidation;
  }

  void _setMeeting(BuildContext context, String type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomSuccessDialog(
        title: type == 'Online'
            ? 'Online Meeting has been set!'
            : 'Offline Meeting has been set!',
        message: type == 'Online'
            ? 'Departement team member will receive an email containing the meeting details and a link to join the online session.'
            : 'You will receive a notification as a reminder of the meeting’s time and physical location.',
      ),
    );
  }

  void _setDate(BuildContext context) {
    DateTime? tempSelectedDate = _selectedDate;
    DateTime tempFocusedDate = _selectedDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.white,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomCalendar(
                    selectedDay: tempSelectedDate ?? DateTime.now(),
                    focusedDay: tempFocusedDate,
                    onDaySelected: (selectedDay, focusedDay) {
                      setDialogState(() {
                        tempSelectedDate = selectedDay;
                        tempFocusedDate = focusedDay;
                      });
                    },
                    eventLoader: (day) {
                      return EventData.getEvents()[
                              DateTime.utc(day.year, day.month, day.day)] ??
                          [];
                    },
                    onEventSelected: (_) {},
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          tempSelectedDate == null
                              ? 'No date selected'
                              : '${tempSelectedDate!.day}/${tempSelectedDate!.month}/${tempSelectedDate!.year}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CustomButton(
                        text: 'Apply',
                        borderRadius: 4,
                        width: 80,
                        height: 36,
                        fontSize: 14,
                        onPressed: () {
                          if (tempSelectedDate != null) {
                            setState(() {
                              _selectedDate = tempSelectedDate;
                            });
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _setTime(BuildContext context) {
    TimeOfDay? tempStartTime = _startTime;
    TimeOfDay? tempEndTime = _endTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Set time',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'From',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 20),
                  TimePickerSpinner(
                    is24HourMode: false,
                    normalTextStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    highlightedTextStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    spacing: 15,
                    itemHeight: 40,
                    onTimeChange: (time) {
                      setDialogState(() {
                        tempStartTime = TimeOfDay(
                          hour: time.hour,
                          minute: time.minute,
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  const Text(
                    'Until',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 20),
                  TimePickerSpinner(
                    is24HourMode: false,
                    normalTextStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    highlightedTextStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    spacing: 15,
                    itemHeight: 40,
                    onTimeChange: (time) {
                      setDialogState(() {
                        tempEndTime = TimeOfDay(
                          hour: time.hour,
                          minute: time.minute,
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          tempStartTime?.format(context) ?? '00:00 AM',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text('-'),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          tempEndTime?.format(context) ?? '00:00 AM',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CustomButton(
                  text: 'Apply',
                  borderRadius: 4,
                  width: 80,
                  height: 36,
                  fontSize: 12,
                  onPressed: () {
                    if (tempStartTime != null && tempEndTime != null) {
                      // Validate time range
                      final startMinutes =
                          tempStartTime!.hour * 60 + tempStartTime!.minute;
                      final endMinutes =
                          tempEndTime!.hour * 60 + tempEndTime!.minute;

                      if (endMinutes <= startMinutes) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('End time must be after start time'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _startTime = tempStartTime;
                        _endTime = tempEndTime;
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greyMainColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: greyMainColor,
        title: Text('Add Meeting',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meeting Title
              FormFieldOne(
                  controller: _titleController,
                  labelText: 'Meeting Title',
                  hintText: 'Enter your meeting title',
                  onChanged: (value) => _onFormChanged()),

              const SizedBox(height: 16),

              // Meeting Type
              const Text(
                'Meeting Type',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              CustomDropdownFormField(
                hint: 'Select',
                value: _selectedType,
                items: ['Online', 'Offline'],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
              ),

              const SizedBox(height: 16),

              const Text(
                'Department',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Obx(() => CustomDropdownFormField(
                    hint: 'Select',
                    value: _selectedDepartment,
                    items: _departmentController.departments
                        .map((d) => d.department)
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDepartment = newValue;
                        final selected = _departmentController.departments
                            .firstWhere((d) => d.department == newValue);
                        _departmentController.selectDepartment(selected);
                        _selectedTeamDepartment = [];
                        _selectedTeamMembers = [];
                        _departmentController.teamDepartments.clear();
                        _departmentController.teamUsers.clear();
                      });
                    },
                  )),

              const SizedBox(height: 16),

              const Text(
                'Head Department',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Obx(() {
                final selectedDept = _departmentController.departments
                    .firstWhereOrNull(
                        (d) => d.department == _selectedDepartment);
                final headName = selectedDept?.managerDepartment ?? '-';
                return Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: greyMainColor),
                  ),
                  child: Text(
                    headName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                );
              }),

              const SizedBox(height: 16),

              const Text(
                'Team Department',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Obx(() => CustomMultiSelect(
                    whenEmpty: 'Select Team Departments',
                    options: _departmentController.teamDepartments
                        .map((team) => team.name)
                        .toList(),
                    selectedValues: _selectedTeamDepartment,
                    onChanged: (values) {
                      setState(() {
                        _selectedTeamDepartment = values;
                        // Ambil semua team yang dipilih
                        final selectedTeams = _departmentController
                            .teamDepartments
                            .where((d) => values.contains(d.name))
                            .toList();
                        // Panggil controller untuk load user dari semua team yang dipilih
                        _departmentController.selectTeams(selectedTeams);
                        // Reset pilihan user jika tim berubah
                        _selectedTeamMembers = [];
                      });
                    },
                  )),

              const SizedBox(height: 16),

              const Text(
                'Department Team Member',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Obx(() => CustomMultiSelect(
                    options: _departmentController.teamUsers
                        .map((user) => user.name)
                        .toList(),
                    selectedValues: _selectedTeamMembers,
                    onChanged: (values) {
                      setState(() {
                        _selectedTeamMembers = values;
                      });
                    },
                    whenEmpty: 'Select team members (max 3)',
                    maxSelection: 3,
                  )),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _setDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: greyMainColor),
                            ),
                            child: Text(
                              _selectedDate == null
                                  ? 'Select'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? Colors.grey[400]
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 1),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            _setTime(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: greyMainColor),
                            ),
                            child: Text(
                              _startTime == null || _endTime == null
                                  ? 'Select time'
                                  : '${_startTime!.format(context)} - ${_endTime!.format(context)}',
                              style: TextStyle(
                                color: _startTime == null
                                    ? Colors.grey[400]
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Description (only show if Online is selected, at the bottom)
              if (_selectedType == 'Online') ...[
                const SizedBox(height: 16),
                FormFieldOne(
                  controller: _descriptionController,
                  labelText: 'Description',
                  hintText: 'Add a link or description',
                  maxLines: 3,
                  onChanged: (value) => _onFormChanged(),
                ),
              ],
              const SizedBox(height: 22),
              CustomButton(
                text: 'Set Meeting',
                isEnabled: _isFormValid(),
                onPressed: _isFormValid()
                    ? () {
                        Navigator.of(context).pop();
                        _setMeeting(context, _selectedType ?? '');
                      }
                    : null,
              )
            ],
          ),
        ),
      ),
    );
  }
}
