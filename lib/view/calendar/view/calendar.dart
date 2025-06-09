import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/color/colors.dart';
import '../../../widget_global/custom_button/custom_button.dart';
import '../model/event.dart';
import '../model/event_utils.dart';
import '../widget/custom_calendar.dart';
import '../widget/event_details_dialog.dart';
import '../model/event_data.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final Map<DateTime, List<Event>> _events;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _events = EventData.getEvents();
  }

  void _showEventDetails(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) => EventDetailsDialog(
        event: event,
        selectedDay: _selectedDay,
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
                CustomCalendar(
                focusedDay: _focusedDay,
                selectedDay: _selectedDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getEventsForDay,
                onEventSelected: (event) => _showEventDetails(context, event),
              ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        text: 'Add Meeting',
                        onPressed: () => context.push('/addMeeting'),
                        borderRadius: 4,
                        height: 40,
                        width: 120,
                        fontSize: 13,
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
                                color: getEventColor(entry.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              getEventTypeTitle(entry.key),
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
