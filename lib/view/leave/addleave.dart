import 'package:flutter/material.dart';

class AddLeavePage extends StatefulWidget {
  const AddLeavePage({super.key});

  @override
  State<AddLeavePage> createState() => _AddLeavePageState();
}

class _AddLeavePageState extends State<AddLeavePage> {
  final TextEditingController _leaveTitleController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String? selectedLeaveType;
  String? selectedDepartment;
  String? selectedHeadDepartment;
  String? selectedTeamDepartment;
  DateTime? startDate;
  DateTime? endDate;
  
  bool isLeaveTypeExpanded = false;
  bool isDepartmentExpanded = false;
  bool isHeadDepartmentExpanded = false;
  bool isTeamDepartmentExpanded = false;
  bool hasUploadedImage = false;
  
  List<String> leaveTypes = ['Sick Leave', 'Paid Leave'];
  List<String> departments = ['IT', 'HRD', 'Marketing', 'Finance'];
  List<String> headDepartments = ['Head department'];
  List<String> teamDepartments = ['Team Adit', 'Team Denis'];

  @override
  void initState() {
    super.initState();
    
    // Tambahkan listeners untuk update state ketika text berubah
    _leaveTitleController.addListener(_updateFormState);
    _employeeIdController.addListener(_updateFormState);
    _fullNameController.addListener(_updateFormState);
    _descriptionController.addListener(_updateFormState);
  }

  @override
  void dispose() {
    // Remove listeners sebelum dispose controllers
    _leaveTitleController.removeListener(_updateFormState);
    _employeeIdController.removeListener(_updateFormState);
    _fullNameController.removeListener(_updateFormState);
    _descriptionController.removeListener(_updateFormState);
    
    // Dispose controllers
    _leaveTitleController.dispose();
    _employeeIdController.dispose();
    _fullNameController.dispose();
    _descriptionController.dispose();
    
    super.dispose();
  }

  // Method helper untuk update state
  void _updateFormState() {
    setState(() {
      // setState akan trigger rebuild untuk mengecek validasi form
    });
  }

  // Method untuk validasi form - semua field harus terisi
  bool _isFormValid() {
    return _leaveTitleController.text.trim().isNotEmpty &&
           _employeeIdController.text.trim().isNotEmpty &&
           _fullNameController.text.trim().isNotEmpty &&
           selectedLeaveType != null &&
           selectedDepartment != null &&
           selectedHeadDepartment != null &&
           selectedTeamDepartment != null &&
           startDate != null &&
           endDate != null &&
           hasUploadedImage &&
           _descriptionController.text.trim().isNotEmpty;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leave Title
            _buildInputField(
              label: 'Leave title',
              controller: _leaveTitleController,
              hintText: 'Enter your leave title',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            
            const SizedBox(height: 20),
            
            // Employee ID Number
            _buildInputField(
              label: 'Employee ID number',
              controller: _employeeIdController,
              hintText: 'Enter your employee ID number',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            
            const SizedBox(height: 20),
            
            // Full Name
            _buildInputField(
              label: 'Full name',
              controller: _fullNameController,
              hintText: 'Enter your full name',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            
            const SizedBox(height: 20),
            
            // Leave Type
            _buildDropdownField(
              label: 'Leave type',
              value: selectedLeaveType,
              items: leaveTypes,
              isExpanded: isLeaveTypeExpanded,
              onTap: () {
                setState(() {
                  isLeaveTypeExpanded = !isLeaveTypeExpanded;
                  isDepartmentExpanded = false;
                  isHeadDepartmentExpanded = false;
                  isTeamDepartmentExpanded = false;
                });
              },
              onSelect: (value) {
                setState(() {
                  selectedLeaveType = value;
                  isLeaveTypeExpanded = false;
                });
              },
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            
            const SizedBox(height: 20),
            
            // Department
            _buildDropdownField(
              label: 'Department',
              value: selectedDepartment,
              items: departments,
              isExpanded: isDepartmentExpanded,
              onTap: () {
                setState(() {
                  isDepartmentExpanded = !isDepartmentExpanded;
                  isLeaveTypeExpanded = false;
                  isHeadDepartmentExpanded = false;
                  isTeamDepartmentExpanded = false;
                });
              },
              onSelect: (value) {
                setState(() {
                  selectedDepartment = value;
                  isDepartmentExpanded = false;
                });
              },
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            
            const SizedBox(height: 20),
            
            // Head Department
            _buildDropdownField(
              label: 'Head department',
              value: selectedHeadDepartment,
              items: headDepartments,
              isExpanded: isHeadDepartmentExpanded,
              onTap: () {
                setState(() {
                  isHeadDepartmentExpanded = !isHeadDepartmentExpanded;
                  isLeaveTypeExpanded = false;
                  isDepartmentExpanded = false;
                  isTeamDepartmentExpanded = false;
                });
              },
              onSelect: (value) {
                setState(() {
                  selectedHeadDepartment = value;
                  isHeadDepartmentExpanded = false;
                });
              },
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            
            const SizedBox(height: 20),
            
            // Team Department
            _buildDropdownField(
              label: 'Team department',
              value: selectedTeamDepartment,
              items: teamDepartments,
              isExpanded: isTeamDepartmentExpanded,
              onTap: () {
                setState(() {
                  isTeamDepartmentExpanded = !isTeamDepartmentExpanded;
                  isLeaveTypeExpanded = false;
                  isDepartmentExpanded = false;
                  isHeadDepartmentExpanded = false;
                });
              },
              onSelect: (value) {
                setState(() {
                  selectedTeamDepartment = value;
                  isTeamDepartmentExpanded = false;
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
            
            // Proof of Superior Approval
            _buildImageUploadField(
              label: 'Proof of superior approval',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            
            const SizedBox(height: 20),
            
            // Description
            _buildTextAreaField(
              label: 'Description',
              controller: _descriptionController,
              hintText: 'Add a description',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            
            const SizedBox(height: 30),

            // Set Leave Button
            _buildSetLeaveButton(),

            const SizedBox(height: 100), // Extra space for bottom navigation
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        backgroundColor: colorScheme.surface,
        elevation: 8,
        currentIndex: 4, // Leave tab is selected
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings_outlined),
            label: 'Salary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: 'Leave',
          ),
        ],
      ),
    );
  }

  // Set Leave Button Widget - Enhanced with proper validation and styling
  Widget _buildSetLeaveButton() {
    final bool isFormComplete = _isFormValid();
    
    return Container(
      width: double.infinity, // Full width sesuai permintaan
      height: 50, // Height sesuai spesifikasi
      margin: const EdgeInsets.symmetric(horizontal: 0), // No additional margin since using full width
      child: ElevatedButton(
        onPressed: isFormComplete ? _handleSetLeave : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormComplete 
              ? const Color(0xFF2463EB) // Blue when enabled
              : const Color(0xFFE3E3E3), // Gray when disabled
          foregroundColor: isFormComplete 
              ? Colors.white 
              : const Color(0xFF9CA3AF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: const Color(0xFFE3E3E3),
          disabledForegroundColor: const Color(0xFF9CA3AF),
        ),
        child: const Text(
          'Set Leave',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Handle Set Leave button press
  void _handleSetLeave() {
    if (_isFormValid()) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave request submitted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Optional: Navigate back or to another screen
      // Navigator.pop(context);
      
      // Optional: Reset form after successful submission
      // _resetForm();
    } else {
      // Show error message if somehow validation fails
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Optional: Method to reset form
  void _resetForm() {
    setState(() {
      _leaveTitleController.clear();
      _employeeIdController.clear();
      _fullNameController.clear();
      _descriptionController.clear();
      selectedLeaveType = null;
      selectedDepartment = null;
      selectedHeadDepartment = null;
      selectedTeamDepartment = null;
      startDate = null;
      endDate = null;
      hasUploadedImage = false;
    });
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

  Widget _buildInputField({
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required bool isExpanded,
    required VoidCallback onTap,
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
                  value ?? 'Select',
                  style: textTheme.bodyMedium?.copyWith(
                    color: value != null 
                        ? colorScheme.onSurface 
                        : colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: items.map((item) {
                return GestureDetector(
                  onTap: () => onSelect(item),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      item,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
      dateText = '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    } else if (startDate != null) {
      dateText = _formatDate(startDate);
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
          onTap: () {
            // Simulasi upload image - implementasi real bisa menggunakan image_picker
            setState(() {
              hasUploadedImage = !hasUploadedImage; // Toggle untuk testing
            });
            
            // Show feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(hasUploadedImage ? 'Image uploaded successfully!' : 'Image removed'),
                backgroundColor: hasUploadedImage ? Colors.green : Colors.orange,
                duration: const Duration(seconds: 1),
              ),
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
              children: [
                Icon(
                  hasUploadedImage ? Icons.check_circle : Icons.image_outlined,
                  color: hasUploadedImage 
                      ? Colors.green 
                      : colorScheme.onSurface.withOpacity(0.4),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  hasUploadedImage ? 'Image uploaded' : 'Select image',
                  style: textTheme.bodyMedium?.copyWith(
                    color: hasUploadedImage
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
  State<CustomDateRangePickerDialog> createState() => _CustomDateRangePickerDialogState();
}

class _CustomDateRangePickerDialogState extends State<CustomDateRangePickerDialog> {
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
      currentMonth = DateTime(selectedStartDate!.year, selectedStartDate!.month);
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
                          currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                        });
                      },
                      icon: const Icon(Icons.chevron_left, size: 20),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                        });
                      },
                      icon: const Icon(Icons.chevron_right, size: 20),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                                color: day == 'Sun'? Colors.red : Colors.grey[700],
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
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                        color: selectedStartDate != null ? Colors.black : Color(0xFF858585),
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
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                        color: selectedEndDate != null ? Colors.black : Color(0xFF858585),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: selectedStartDate != null ? () {
                      widget.onDateRangeSelected(selectedStartDate, selectedEndDate);
                      Navigator.of(context).pop();
                    } : null,
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
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
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
  final isStartDate = selectedStartDate != null && _isSameDay(date, selectedStartDate!);
  final isEndDate = selectedEndDate != null && _isSameDay(date, selectedEndDate!);
  
  return GestureDetector(
    onTap: () => _selectDate(date),
    child: Container(
      height: 40,
      decoration: BoxDecoration(
        color: _getBackgroundColor(date, isSelected, isInRange, isStartDate, isEndDate, isToday),
        borderRadius: _getBorderRadius(isStartDate, isEndDate, isSelected, isInRange, isToday),
        border: _getBorder(isStartDate, isEndDate, isToday, isInRange),
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            fontSize: 14,
            color: _getTextColor(date, isSelected, isInRange, isStartDate, isEndDate, isToday, isWeekend),
            fontWeight: (isSelected || isStartDate || isEndDate || isToday) ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    ),
  );
}

// Helper methods untuk styling
Color _getBackgroundColor(DateTime date, bool isSelected, bool isInRange, bool isStartDate, bool isEndDate, bool isToday) {
  if (isStartDate || isEndDate) {
    return Color(0xFF007AFF).withOpacity(0.2); // Blue color untuk start/end date
  } else if (isInRange) {
    return Colors.white; // White background untuk range
  } else if (isToday && !isSelected && !isStartDate && !isEndDate) {
    return Color(0xFF007AFF); // Blue background untuk today
  }
  return Colors.transparent;
}

BorderRadius _getBorderRadius(bool isStartDate, bool isEndDate, bool isSelected, bool isInRange, bool isToday) {
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

Border? _getBorder(bool isStartDate, bool isEndDate, bool isToday, bool isInRange) {
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

Color _getTextColor(DateTime date, bool isSelected, bool isInRange, bool isStartDate, bool isEndDate, bool isToday, bool isWeekend) {
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
    return (selectedStartDate != null && _isSameDay(date, selectedStartDate!)) ||
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
      if (selectedStartDate == null || (selectedStartDate != null && selectedEndDate != null)) {
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
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}