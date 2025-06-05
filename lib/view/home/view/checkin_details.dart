import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CheckInDetailsPage extends StatefulWidget {
  const CheckInDetailsPage({super.key});

  @override
  State<CheckInDetailsPage> createState() => _CheckInDetailsPageState();
}

class _CheckInDetailsPageState extends State<CheckInDetailsPage> {
  DateTime selectedDate = DateTime.now();

  void _pickDate() async {
    await showCustomCalendarDialog(context, selectedDate, (picked) {
      setState(() {
        selectedDate = picked;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock In details'),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(dateStr,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 200, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {},
                    child: const Text("Clock Out",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ClockInfo(
                        iconWidget: Image.asset(
                          'assets/icon/Clock_fill.png',
                          width: 24,
                          height: 24,
                        ),
                        label: '08:00 AM',
                        subLabel: 'Clock In',
                      ),
                      _ClockInfo(
                        iconWidget: Image.asset(
                          'assets/icon/Clock_fill.png',
                          width: 24,
                          height: 24,
                        ),
                        label: '04:00 PM',
                        subLabel: 'Clock Out',
                      ),
                      _ClockInfo(
                        iconWidget: Image.asset(
                          'assets/icon/Clock_fill.png',
                          width: 24,
                          height: 24,
                        ),
                        label: '00:00:00 AM',
                        subLabel: 'Working HR\'s',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Schedule',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _pickDate,
                  label: const Text('Today'),
                  icon: const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2463EB),),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: const [
                  _ScheduleItem(
                      time: '08:00',
                      label: 'Check In time',
                      color: Colors.green,
                      timeBox: '07:50'),
                  _ScheduleItem(time: '09:00', label: '', color: Colors.grey),
                  _ScheduleItem(time: '10:00', label: '', color: Colors.grey),
                  _ScheduleItem(
                      time: '11:00',
                      label: 'Break time',
                      color: Colors.amber,
                      timeBox: '07:50'),
                  _ScheduleItem(
                      time: '16:00',
                      label: 'Clock Out time',
                      color: Colors.red,
                      timeBox: '07:50'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCustomCalendarDialog(BuildContext context,
    DateTime selectedDate, Function(DateTime) onDateSelected) async {
  DateTime tempPicked = selectedDate;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TableCalendar(
                    focusedDay: tempPicked,
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    selectedDayPredicate: (day) => isSameDay(day, tempPicked),
                    onDaySelected: (selected, _) {
                      setState(() => tempPicked = selected);
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2463EB),
                          width: 2,
                        ),
                      ),
                      selectedDecoration: BoxDecoration(
                        color: const Color.fromRGBO(36, 99, 235, 1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color.fromRGBO(36, 99, 235, 1),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      todayTextStyle: const TextStyle(
                        color: Color(0xFF2463EB), 
                      ),
                      selectedTextStyle: const TextStyle(color: Colors.white),
                      weekendTextStyle: const TextStyle(color: Colors.red),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekendStyle: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(tempPicked),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(36, 99, 235, 1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          onDateSelected(tempPicked);
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Apply',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

class _ClockInfo extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final String subLabel;

  const _ClockInfo({
    required this.iconWidget,
    required this.label,
    required this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        iconWidget,
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(subLabel, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String time;
  final String label;
  final Color color;
  final String? timeBox;

  const _ScheduleItem(
      {required this.time,
      required this.label,
      required this.color,
      this.timeBox});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Text(
              time,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label.isEmpty ? '—' : label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (timeBox != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '($timeBox)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
