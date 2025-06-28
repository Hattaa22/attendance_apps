import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/color/colors.dart';
import '../model/event.dart';
import '../model/event_utils.dart';

class CustomCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<Event> Function(DateTime) eventLoader;
  final Function(Event) onEventSelected;

  const CustomCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.eventLoader,
    required this.onEventSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Event>(
      firstDay: DateTime(DateTime.now().year, 1, 1),
      lastDay: DateTime(DateTime.now().year, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      rowHeight: 40,
      daysOfWeekHeight: 25,
      onDaySelected: onDaySelected,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: false,
        leftChevronVisible: false,
        rightChevronVisible: false,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        headerPadding: const EdgeInsets.only(bottom: 10),
        headerMargin: EdgeInsets.zero,
      ),
      headerVisible: true,
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(color: redMainColor),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekendStyle: TextStyle(color: redMainColor),
      ),
      eventLoader: eventLoader,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          bool isToday = isSameDay(date, DateTime.now());
          bool isSelected = isSameDay(date, selectedDay);
          bool isFocused = isSameDay(date, focusedDay);

          if (events.isEmpty || isSelected || isToday || isFocused) {
            return const SizedBox();
          }

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
                    color: getEventColor(event.type),
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
        headerTitleBuilder: (context, date) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      if (focusedDay.isAfter(DateTime(DateTime.now().year, 1, 1))) {
                        onDaySelected(
                          selectedDay,
                          DateTime(focusedDay.year, focusedDay.month - 1),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      if (focusedDay.isBefore(DateTime(DateTime.now().year, 12, 1))) {
                        onDaySelected(
                          selectedDay,
                          DateTime(focusedDay.year, focusedDay.month + 1),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}