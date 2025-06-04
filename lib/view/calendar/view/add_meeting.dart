import 'package:flutter/material.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:multiselect/multiselect.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:fortis_apps/widget_global/show_dialog_success/dialog_success.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class AddMeetingPage extends StatefulWidget {
  const AddMeetingPage({super.key});

  @override
  State<AddMeetingPage> createState() => _AddMeetingPageState();
}

class _AddMeetingPageState extends State<AddMeetingPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<String> _selectedTeamMembers = [];
  DateTime? _selectedDate;
  String? _selectedType;
  String? _selectedDepartment;
  String? _selectedHeadDepartment;
  String? _selectedTeamDepartment;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {
      
    });
  }

  bool _isFormValid() {
  // Base validation for required fields
  bool baseValidation = _titleController.text.isNotEmpty &&
      _selectedType != null &&
      _selectedDepartment != null &&
      _selectedHeadDepartment != null &&
      _selectedTeamDepartment != null &&
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
        title: type == 'Online' ? 'Online Meeting has been set!' : 'Offline Meeting has been set!',
        message: type == 'Online' ? 'Departement team member will receive an email containing the meeting details and a link to join the online session.' : 'You will receive a notification as a reminder of the meeting’s time and physical location.',
      ),
    );
  }

  void _setDate(BuildContext context) {
  DateTime? tempSelectedDate = _selectedDate;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CalendarDatePicker2(
                  config: CalendarDatePicker2Config(
                  calendarType: CalendarDatePicker2Type.single,
                  selectedDayHighlightColor: blueMainColor,
                  weekdayLabelTextStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  controlsTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  dayTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                  selectedDayTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  firstDate: DateTime(DateTime.now().year, 1, 1),
                  lastDate: DateTime(DateTime.now().year, 12, 31),
                  ),
                  value: tempSelectedDate != null ? [tempSelectedDate] : [],
                  onValueChanged: (dates) {
                    // Update the temporary date and rebuild dialog
                    setDialogState(() {
                      tempSelectedDate = dates.first;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueMainColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () {
                        if (tempSelectedDate != null) {
                          setState(() {
                            _selectedDate = tempSelectedDate;
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ],
                  ),
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
                    spacing: 30,
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
                    spacing: 30,
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueMainColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                  ),
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
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
              const Text(
                'Meeting Title',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hoverColor: Colors.white,
                  focusColor: Colors.white,
                  hintText: 'Enter your meeting title',
                  hintStyle: TextStyle(color: Color.fromRGBO(165, 165, 165, 1)),
                  errorStyle: TextStyle(color: Colors.red),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: greyMainColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: greyMainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 16),

              // Meeting Type
              const Text(
                'Meeting Type',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                hint: const Text('Select'),
                value: _selectedType,
                items: <String>['Online', 'Offline'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedType = newValue;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hoverColor: Colors.white,
                  focusColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: greyMainColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: greyMainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Department',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                hint: const Text('Select'),
                value: _selectedDepartment,
                items: <String>['IT', 'HRD', 'Marketing', 'Finance']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDepartment = newValue;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hoverColor: Colors.white,
                  focusColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: greyMainColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: greyMainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Head Department',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                hint: const Text('Select'),
                value: _selectedHeadDepartment,
                items: <String>['Head Department'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedHeadDepartment = newValue;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hoverColor: Colors.white,
                  focusColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: greyMainColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: greyMainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Team Department',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                hint: const Text('Select'),
                value: _selectedTeamDepartment,
                items: <String>['Team Adit', 'Team Denis'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTeamDepartment = newValue;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hoverColor: Colors.white,
                  focusColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: greyMainColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: greyMainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),

              const SizedBox(height: 16),

              // Check Again !!!
              const Text(
                'Department Team Member',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropDownMultiSelect(
                onChanged: (List<String> x) {
                  setState(() {
                    if (x.length <= 3) {
                      _selectedTeamMembers = x;
                    } else {
                      // Show snackbar when trying to select more than 3 members
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('You can only select up to 3 team members'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  });
                },
                options: const [
                  'Adit',
                  'Denis',
                  'Budi',
                  'Joko',
                  'Joni',
                  'Jono',
                  'Jone'
                ],
                selectedValues: _selectedTeamMembers,
                whenEmpty: 'Select team members (max 3)',
                childBuilder: (selectedValues) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Text(
                      selectedValues.isEmpty
                          ? 'Select team members (max 3)'
                          : selectedValues.join(', '),
                      style: TextStyle(
                        color: selectedValues.isEmpty
                            ? Colors.grey[400]
                            : Colors.black,
                      ),
                    ),
                  );
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: greyMainColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: greyMainColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),

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
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hoverColor: Colors.white,
                    focusColor: Colors.white,
                    hintText: 'Add a link or description',
                    hintStyle:
                        TextStyle(color: Color.fromRGBO(165, 165, 165, 1)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: greyMainColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: greyMainColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _isFormValid()
                    ? () {
                        Navigator.of(context).pop();
                        _setMeeting(context, _selectedType ?? '');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  backgroundColor:
                      _isFormValid() ? blueMainColor : Colors.grey[300],
                  foregroundColor:
                      _isFormValid() ? Colors.white : Colors.grey[500],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Set Meeting',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
