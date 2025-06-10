import '../model/event.dart';

class EventData {
  static Map<DateTime, List<Event>> getEvents() {
    return {
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
}