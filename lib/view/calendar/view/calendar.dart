import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/color/colors.dart';

class Event {
  final String title;
  final String location;
  final String department;
  final String mode;
  final String time;
  final String type;

  Event({
    required this.title,
    required this.location,
    required this.department,
    required this.mode,
    required this.time,
    required this.type,
  });
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final Map<DateTime, List<Event>> _events;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Color _getEventColor(String type) {
    switch (type.toLowerCase()) {
      case 'meeting':
        return yellowMainColor;
      case 'request':
        return greenSecondColor;
      case 'conference':
        return purpleMainColor;
      case 'training':
        return lightBlueColor;
      default:
        return greyNavColor;
    }
  }

  String _getEventTypeTitle(String type) {
    switch (type.toLowerCase()) {
      case 'meeting':
        return 'Meeting';
      case 'request':
        return 'Request';
      case 'conference':
        return 'Conference';
      case 'training':
        return 'Training';
      default:
        return 'Event';
    }
  }

  Map<String, List<Event>> groupEventsByType(List<Event> events) {
    final groupedEvents = <String, List<Event>>{};
    for (var event in events) {
      if (!groupedEvents.containsKey(event.type)) {
        groupedEvents[event.type] = [];
      }
      groupedEvents[event.type]!.add(event);
    }
    return groupedEvents;
  }

  @override
  void initState() {
    super.initState();
    _events = {
      DateTime.utc(2025, 6, 9): [
        Event(
          title: 'Design review',
          location: 'Zoom',
          department: 'UI/UX Team',
          mode: 'Online',
          time: '10:00–11:00',
          type: 'request',
        ),
        Event(
          title: 'Finance Seminar',
          location: 'Meeting Room B',
          department: 'Finance Department',
          mode: 'Offline',
          time: '14:00–15:00',
          type: 'conference',
        ),
      ],
      DateTime.utc(2025, 6, 25): [
        Event(
          title: 'Design meeting to client',
          location: 'Zoom',
          department: 'UI/UX Team',
          mode: 'Online',
          time: '08:00–12:00',
          type: 'meeting',
        ),
        Event(
          title: 'Discuss company finances',
          location: 'Meeting Room A',
          department: 'Finance Department',
          mode: 'Offline',
          time: '13:00–16:00',
          type: 'meeting',
        ),
      ],
      DateTime.utc(2025, 6, 27): [
        Event(
          title: 'Slicing UI Project',
          location: 'Zoom',
          department: 'Dev Team',
          mode: 'Online',
          time: '10:00–11:00',
          type: 'training',
        ),
      ],
    };
  }

  void _showEventDetails(BuildContext context, Event event) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: greyMainColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: const Text(
                        'Meeting details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Meeting title', event.title),
                    _buildDetailRow('Meeting type', event.mode.toLowerCase()),
                    _buildDetailRow('Department', event.department),
                    _buildDetailRow('Head department', 'head department'),
                    _buildDetailRow('Team department', 'Team adit'),
                    _buildDetailRow('Department team member', 'Adit, Sopo, Jarwo'),
                    _buildDetailRow('Date', DateFormat('dd/MM/yyyy').format(_selectedDay)),
                    _buildDetailRow('Time', event.time),
                    if (event.mode.toLowerCase() == 'online') ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Link & Description:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'https://zoom.us/meeting/abc123',
                        style: TextStyle(
                          fontSize: 14,
                          color: blueMainColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                    backgroundColor: blueMainColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                  child: const Text(
                    'Okay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final eventsToday = _getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: greyMainColor,
        title: Text(
          'Calendar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: greyMainColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TableCalendar<Event>(
                    firstDay: DateTime(DateTime.now().year, 1, 1),
                    lastDay: DateTime(DateTime.now().year, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                    rowHeight: 40,
                    daysOfWeekHeight: 25,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      weekendTextStyle: TextStyle(color: redMainColor),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekendStyle: TextStyle(color: redMainColor),
                    ),
                    eventLoader: _getEventsForDay,
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isEmpty || isSameDay(date, _selectedDay))
                          return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 2,
                            children: events.take(5).map((event) {
                              return Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getEventColor(event.type),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                      todayBuilder: (context, date, _) => Center(
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: blueMainColor,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      selectedBuilder: (context, date, _) => Center(
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: blueMainColor),
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(color: blueMainColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.push('/addMeeting');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueMainColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text("Add Meeting",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Events List
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Events",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            if (eventsToday.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Text("No events for this day."),
              )
            else
              ...groupEventsByType(eventsToday).entries.map((entry) =>
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event type header with dot
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getEventColor(entry.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getEventTypeTitle(entry.key),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        // List of events of this type
                        ...entry.value.map((event) => GestureDetector(
                              onTap: () => _showEventDetails(context, event),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Color(0xFFE0E0E0),
                                  ),
                                  const SizedBox(height: 10),
                                  // Date and Time
                                  Row(
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(_selectedDay),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: greyNavColor,
                                        ),
                                      ),
                                      Text(
                                        ' | ${event.time}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: greyNavColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Mode (Online/Offline)
                                  Text(
                                    event.mode,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: blueMainColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Event Title
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Department
                                  Text(
                                    event.department,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: greyNavColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  )),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
