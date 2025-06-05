import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  bool clockInEnabled = true;
  bool clockOutEnabled = false;
  
  TimeOfDay clockInTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay clockOutTime = const TimeOfDay(hour: 16, minute: 0);
  
  List<String> clockInDays = ['S', 'T', 'F', 'S']; // Sun, Tue, Fri, Sat
  List<String> clockOutDays = ['S', 'T', 'F', 'S']; // Sun, Tue, Fri, Sat
  
  final List<String> allDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<String> dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  'Set Reminder Saved!',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  'Reminder has been successfully scheduled for activity, June 16, 2025 at 08:00 AM - 04:00 PM. We will send notification as scheduled.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2463EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Okay!',
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
       backgroundColor: const Color(0xFF2463EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reminder',
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Clock In Reminder
                  _buildReminderCard(
                    title: 'Active Clock In Reminder',
                    time: clockInTime,
                    isEnabled: clockInEnabled,
                    selectedDays: clockInDays,
                    onToggle: (value) {
                      setState(() {
                        clockInEnabled = value;
                      });
                    },
                    onTimeChanged: (time) {
                      setState(() {
                        clockInTime = time;
                      });
                    },
                    onDayToggle: (day) {
                      setState(() {
                        if (clockInDays.contains(day)) {
                          clockInDays.remove(day);
                        } else {
                          clockInDays.add(day);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // Clock Out Reminder
                  _buildReminderCard(
                    title: 'Active Clock Out Reminder',
                    time: clockOutTime,
                    isEnabled: clockOutEnabled,
                    selectedDays: clockOutDays,
                    isPM: true,
                    onToggle: (value) {
                      setState(() {
                        clockOutEnabled = value;
                      });
                    },
                    onTimeChanged: (time) {
                      setState(() {
                        clockOutTime = time;
                      });
                    },
                    onDayToggle: (day) {
                      setState(() {
                        if (clockOutDays.contains(day)) {
                          clockOutDays.remove(day);
                        } else {
                          clockOutDays.add(day);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showSuccessDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2463EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard({
    required String title,
    required TimeOfDay time,
    required bool isEnabled,
    required List<String> selectedDays,
    bool isPM = false,
    required Function(bool) onToggle,
    required Function(TimeOfDay) onTimeChanged,
    required Function(String) onDayToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: const Color(0xFF2463EB),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Time Display
          GestureDetector(
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (picked != null) {
                onTimeChanged(picked);
              }
            },
            child: Row(
              children: [
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.roboto(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF2463EB),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isPM ? 'PM' : 'AM',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2463EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Repeat days label
          Text(
            'Repeat on : Sun, Tue, Fri, Sat',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          // Day selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: allDays.asMap().entries.map((entry) {
              int index = entry.key;
              String day = entry.value;
              bool isSelected = selectedDays.contains(day);
              
              return GestureDetector(
                onTap: () => onDayToggle(day),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2463EB) : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      day,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}