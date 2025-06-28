import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fortis_apps/core/data/repositories/leave_repository.dart';
import 'package:fortis_apps/core/data/repositories/profile_repository.dart';
import 'package:fortis_apps/core/data/services/auth_service.dart';
import 'package:fortis_apps/core/data/repositories/auth_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddLeavePage extends StatefulWidget {
  const AddLeavePage({super.key});

  @override
  State<AddLeavePage> createState() => _AddLeavePageState();
}

class _AddLeavePageState extends State<AddLeavePage> {
  final TextEditingController _reasonController = TextEditingController();
  final LeaveRepository _leaveRepo = LeaveRepositoryImpl();
  final AuthRepository _authRepo = AuthRepositoryImpl();
  final ProfileRepository _profileRepo = ProfileRepositoryImpl();

  String? selectedLeaveType;
  DateTime? startDate;
  DateTime? endDate;
  File? _proofFile;
  bool _isLoading = false;
  String? _errorMessage;

  String? _userNip;
  String? _fullName;

  String? _department;
  String? _headDepartment;
  String? _teamDepartment;

  List<String> leaveTypes = [
    'paid',
    'sick',
    'emergency',
    'maternity',
    'paternity'
  ];

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(_updateFormState);
    _loadUserData();
    _loadProfileData();
  }

  Future<void> _loadUserData() async {
    final result = await _authRepo.getCurrentUser();

    if (result != null && result['success'] == true) {
      final userData = result['user'];

      setState(() {
        _userNip = userData['nip']?.toString();
        _fullName =
            userData['name']?.toString() ?? userData['fullName']?.toString();
      });
    } else {
      final message = result?['message'] ?? 'Failed to load user data';
      print('Error loading user: $message');
    }
  }

  Future<void> _loadProfileData() async {
    final result = await _profileRepo.getProfile();
    if (result['success'] == true) {
      final profileData = result['profile'];
      setState(() {
        _department = profileData['department']?.toString();
        _headDepartment = profileData['manager_department']?.toString();
        _teamDepartment = profileData['team_department']?.toString();
      });
    }
  }

  @override
  void dispose() {
    _reasonController.removeListener(_updateFormState);
    _reasonController.dispose();
    super.dispose();
  }

  void _updateFormState() {
    setState(() {});
  }

  bool _isFormValid() {
    return _reasonController.text.trim().isNotEmpty &&
        selectedLeaveType != null &&
        startDate != null &&
        endDate != null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 244, 244, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(244, 244, 244, 1),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF000000),
          ),
        ),
        title: Text(
          'Add Leave',
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF000000),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Employee ID (non-editable)
                  _buildNonEditableField(
                    label: 'Employee ID number',
                    value: _userNip ?? 'Loading...',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 20),

                  // Full Name (non-editable)
                  _buildNonEditableField(
                    label: 'Full name',
                    value: _fullName ?? 'Loading...',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),

                  // Department (non-editable)
                  _buildNonEditableField(
                    label: 'Department',
                    value: _department ?? 'Loading...',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 20),

                  // Head Department (non-editable)
                  _buildNonEditableField(
                    label: 'Head department',
                    value: _headDepartment ?? 'Loading...',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 20),

                  // Team Department (non-editable)
                  _buildNonEditableField(
                    label: 'Team department',
                    value: _teamDepartment ?? 'Loading...',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 20),

                  // Leave Type
                  _buildDropdownField(
                    label: 'Leave type',
                    value: selectedLeaveType != null
                        ? _formatLeaveType(selectedLeaveType!)
                        : null,
                    items: leaveTypes
                        .map((type) => _formatLeaveType(type))
                        .toList(),
                    onSelect: (value) {
                      setState(() {
                        selectedLeaveType = leaveTypes.firstWhere(
                          (type) => _formatLeaveType(type) == value,
                        );
                      });
                    },
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 20),

                  // Date Range
                  _buildDateRangeField(
                    label: 'Date',
                    startDate: startDate,
                    endDate: endDate,
                    onTap: () => _showCustomDateRangePicker(context),
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 20),

                  // Proof of Superior Approval (optional)
                  _buildImageUploadField(
                    label: 'Proof (optional)',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 20),

                  // Reason
                  _buildTextAreaField(
                    label: 'Reason',
                    controller: _reasonController,
                    hintText: 'Add a reason',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),

                  const SizedBox(height: 30),

                  // Set Leave Button
                  _buildSetLeaveButton(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  String _formatLeaveType(String type) {
    switch (type) {
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

  Widget _buildNonEditableField({
    required String label,
    required String value,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSetLeaveButton() {
    final bool isFormComplete = _isFormValid();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isFormComplete ? _handleSetLeave : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormComplete
              ? const Color(0xFF2463EB) // Blue when enabled
              : const Color(0xFFE3E3E3), // Gray when disabled
          foregroundColor:
              isFormComplete ? Colors.white : const Color(0xFF9CA3AF),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: const Color(0xFFE3E3E3),
          disabledForegroundColor: const Color(0xFF9CA3AF),
        ),
        child: const Text(
          'Submit Leave Request',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSetLeave() async {
    if (!_isFormValid() || _userNip == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _leaveRepo.applyLeave(
        type: selectedLeaveType!,
        startDate: startDate!,
        endDate: endDate!,
        reason: _reasonController.text,
        proofFilePath: _proofFile?.path,
      );

      if (result['success'] == true) {
        Navigator.pop(context, {
          'success': true,
          'message': result['message'] ?? 'Leave submitted successfully',
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to submit leave';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCustomDateRangePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDateRangePickerDialog(
          initialStartDate: startDate,
          initialEndDate: endDate,
          onDateRangeSelected: (DateTime? start, DateTime? end) {
            setState(() {
              startDate = start;
              endDate = end;
            });
          },
        );
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String) onSelect,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...items.map((item) {
                        return ListTile(
                          title: Text(item),
                          onTap: () {
                            onSelect(item);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? 'Select',
                  style: textTheme.bodyMedium?.copyWith(
                    color: value != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeField({
    required String label,
    required DateTime? startDate,
    required DateTime? endDate,
    required VoidCallback onTap,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    String dateText = 'Select';
    if (startDate != null && endDate != null) {
      dateText =
          '${_formatDateWithDayName(startDate)} - ${_formatDateWithDayName(endDate)}';
    } else if (startDate != null) {
      dateText = _formatDateWithDayName(startDate);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateText,
                  style: textTheme.bodyMedium?.copyWith(
                    color: (startDate != null)
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: colorScheme.onSurface.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateWithDayName(DateTime date) {
    return DateFormat('EEE, dd MMM yyyy').format(date);
  }

  Widget _buildImageUploadField({
    required String label,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _proofFile != null
                      ? Icons.check_circle
                      : Icons.image_outlined,
                  color: _proofFile != null
                      ? Colors.green
                      : colorScheme.onSurface.withOpacity(0.4),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _proofFile != null
                      ? 'File selected'
                      : 'Select file (optional)',
                  style: textTheme.bodyMedium?.copyWith(
                    color: _proofFile != null
                        ? Colors.green
                        : colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _proofFile = File(pickedFile.path);
      });
    }
  }

  Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Date Range Picker Dialog remains the same
class CustomDateRangePickerDialog extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const CustomDateRangePickerDialog({
    Key? key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onDateRangeSelected,
  }) : super(key: key);

  @override
  State<CustomDateRangePickerDialog> createState() =>
      _CustomDateRangePickerDialogState();
}

class _CustomDateRangePickerDialogState
    extends State<CustomDateRangePickerDialog> {
  DateTime currentMonth = DateTime.now();
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  bool isSelectingEndDate = false;

  @override
  void initState() {
    super.initState();
    selectedStartDate = widget.initialStartDate;
    selectedEndDate = widget.initialEndDate;
    if (selectedStartDate != null) {
      currentMonth =
          DateTime(selectedStartDate!.year, selectedStartDate!.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 360,
        height: 335,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with month/year on left and navigation on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getMonthYearString(currentMonth),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          currentMonth = DateTime(
                              currentMonth.year, currentMonth.month - 1);
                        });
                      },
                      icon: const Icon(Icons.chevron_left, size: 20),
                      padding: const EdgeInsets.all(4),
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          currentMonth = DateTime(
                              currentMonth.year, currentMonth.month + 1);
                        });
                      },
                      icon: const Icon(Icons.chevron_right, size: 20),
                      padding: const EdgeInsets.all(4),
                      constraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Days of week header
            Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((day) => Expanded(
                        child: Container(
                          height: 24,
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: day == 'Sun'
                                    ? Colors.red
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 4),

            // Calendar grid
            Expanded(
              child: _buildCalendarGrid(),
            ),

            const SizedBox(height: 12),

            // Date range display
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      selectedStartDate != null
                          ? _formatDate(selectedStartDate!)
                          : '-',
                      style: TextStyle(
                        fontSize: 12,
                        color: selectedStartDate != null
                            ? Colors.black
                            : Color(0xFF858585),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('—', style: TextStyle(fontSize: 14)),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      selectedEndDate != null
                          ? _formatDate(selectedEndDate!)
                          : '-',
                      style: TextStyle(
                        fontSize: 12,
                        color: selectedEndDate != null
                            ? Colors.black
                            : Color(0xFF858585),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: selectedStartDate != null
                        ? () {
                            widget.onDateRangeSelected(
                                selectedStartDate, selectedEndDate);
                            Navigator.of(context).pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;

    List<Widget> dayWidgets = [];

    // Add empty cells for days before the month starts
    for (int i = 0; i < firstDayWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add day cells
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      dayWidgets.add(_buildDayCell(date));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(DateTime date) {
    final isSelected = _isDateSelected(date);
    final isInRange = _isDateInRange(date);
    final isToday = _isToday(date);
    final isWeekend = date.weekday == DateTime.sunday;
    final isStartDate =
        selectedStartDate != null && _isSameDay(date, selectedStartDate!);
    final isEndDate =
        selectedEndDate != null && _isSameDay(date, selectedEndDate!);

    return GestureDetector(
      onTap: () => _selectDate(date),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: _getBackgroundColor(
              date, isSelected, isInRange, isStartDate, isEndDate, isToday),
          borderRadius: _getBorderRadius(
              isStartDate, isEndDate, isSelected, isInRange, isToday),
          border: _getBorder(isStartDate, isEndDate, isToday, isInRange),
        ),
        child: Center(
          child: Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 14,
              color: _getTextColor(date, isSelected, isInRange, isStartDate,
                  isEndDate, isToday, isWeekend),
              fontWeight: (isSelected || isStartDate || isEndDate || isToday)
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

// Helper methods untuk styling
  Color _getBackgroundColor(DateTime date, bool isSelected, bool isInRange,
      bool isStartDate, bool isEndDate, bool isToday) {
    if (isStartDate || isEndDate) {
      return Color(0xFF007AFF)
          .withOpacity(0.2); // Blue color untuk start/end date
    } else if (isInRange) {
      return Colors.white; // White background untuk range
    } else if (isToday && !isSelected && !isStartDate && !isEndDate) {
      return Color(0xFF007AFF); // Blue background untuk today
    }
    return Colors.transparent;
  }

  BorderRadius _getBorderRadius(bool isStartDate, bool isEndDate,
      bool isSelected, bool isInRange, bool isToday) {
    if (isToday && !isStartDate && !isEndDate && !isInRange) {
      // Today: fully rounded seperti gambar
      return BorderRadius.circular(8);
    } else if (isStartDate && !isEndDate) {
      // Start date: rounded left side only
      return BorderRadius.only(
        topLeft: Radius.circular(10),
        bottomLeft: Radius.circular(10),
      );
    } else if (isEndDate && !isStartDate) {
      // End date: rounded right side only
      return BorderRadius.only(
        topRight: Radius.circular(10),
        bottomRight: Radius.circular(10),
      );
    } else if (isStartDate && isEndDate) {
      // Same date selected: fully rounded
      return BorderRadius.circular(10);
    } else if (isInRange) {
      // In range: no border radius untuk efek connected
      return BorderRadius.zero;
    }
    return BorderRadius.zero;
  }

  Border? _getBorder(
      bool isStartDate, bool isEndDate, bool isToday, bool isInRange) {
    if (isToday && !isStartDate && !isEndDate && !isInRange) {
      // Today: no border karena sudah full background
      return null;
    } else if (isStartDate || isEndDate) {
      // Start/End date: border biru transparan
      return Border.all(
        color: Color(0xFF007AFF),
        width: 1,
      );
    } else if (isInRange) {
      // Range: border biru untuk line menyatu
      return Border.all(
        color: Color(0xFF007AFF),
        width: 1,
      );
    }
    return null;
  }

  Color _getTextColor(DateTime date, bool isSelected, bool isInRange,
      bool isStartDate, bool isEndDate, bool isToday, bool isWeekend) {
    if (isStartDate || isEndDate) {
      return Colors.blue; // White text untuk selected dates
    } else if (isToday && !isStartDate && !isEndDate && !isInRange) {
      return Colors.white; // White text untuk today
    } else if (isInRange) {
      return Color(0xFF007AFF); // Blue text untuk dates dalam range
    } else if (isWeekend) {
      return Colors.red; // Red untuk weekend
    }
    return Color(0xFF333333); // Default dark color
  }

  bool _isDateSelected(DateTime date) {
    return (selectedStartDate != null &&
            _isSameDay(date, selectedStartDate!)) ||
        (selectedEndDate != null && _isSameDay(date, selectedEndDate!));
  }

  bool _isDateInRange(DateTime date) {
    if (selectedStartDate == null || selectedEndDate == null) return false;
    return date.isAfter(selectedStartDate!) && date.isBefore(selectedEndDate!);
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return _isSameDay(date, today);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _selectDate(DateTime date) {
    setState(() {
      if (selectedStartDate == null ||
          (selectedStartDate != null && selectedEndDate != null)) {
        // Start new selection
        selectedStartDate = date;
        selectedEndDate = null;
        isSelectingEndDate = true;
      } else if (isSelectingEndDate) {
        // Select end date
        if (date.isBefore(selectedStartDate!)) {
          // If selected date is before start date, swap them
          selectedEndDate = selectedStartDate;
          selectedStartDate = date;
        } else {
          selectedEndDate = date;
        }
        isSelectingEndDate = false;
      }
    });
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
