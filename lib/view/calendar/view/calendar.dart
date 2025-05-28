import 'package:flutter/material.dart';
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
        return Colors.yellow;
      case 'request':
        return Colors.green;
      case 'conference':
        return Colors.purple;
      case 'training':
        return Colors.lightBlue;
      default:
        return Colors.grey;
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
                    eventLoader: _getEventsForDay,
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isEmpty) return const SizedBox();
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueMainColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text("Add Meeting",
                            style: TextStyle(
                                fontSize: 12,
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
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text("No events for this day."),
              )
            else
              ...groupEventsByType(eventsToday)
                  .entries
                  .map((entry) => Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
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
                            ...entry.value.map((event) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 13),
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
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          ' | ${event.time}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Mode (Online/Offline)
                                    Text(
                                      event.mode,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: blueMainColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    // Event Title
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    // Department
                                    Text(
                                      event.department,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
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
