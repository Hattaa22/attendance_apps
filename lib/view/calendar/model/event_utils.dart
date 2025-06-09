import 'package:flutter/material.dart';
import '../../../core/color/colors.dart';
import '../model/event.dart';

Color getEventColor(String type) {
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

String getEventTypeTitle(String type) {
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