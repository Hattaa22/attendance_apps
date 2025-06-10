import 'package:fortis_apps/view/auth/login/view/login_screen.dart';
import 'package:fortis_apps/view/auth/reset_password/view/reset_password.dart';
import 'package:fortis_apps/view/calendar/view/add_meeting.dart';
import 'package:fortis_apps/view/calendar/view/calendar.dart';
import 'package:fortis_apps/view/home/view/home.dart';
import 'package:fortis_apps/view/profile/view/change_password.dart';
import 'package:fortis_apps/view/splash_screen/splash_screen.dart';
import 'package:fortis_apps/view/home/view/notification.dart';
import 'package:fortis_apps/view/home/view/reminder.dart';
import 'package:fortis_apps/view/home/view/checkin_details.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      name: 'splash',
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: '/login',
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: '/resetPassword',
      path: '/resetPassword',
      builder: (context, state) => const ResetPasswordPage(),
    ),
    GoRoute(
      name: '/home',
      path: '/home',
      builder: (context, state) => const Home(),
    ),
    GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarPage(),
          // routes: [
          //   GoRoute(
          //     path: 'add',  // This will make the path /calendar/add
          //     builder: (context, state) => const AddMeetingPage(),
          //   ),
          // ],
        ),
      GoRoute(
      name: '/addMeeting',
      path: '/addMeeting',
      builder: (context, state) => const AddMeetingPage(),
    ),
    GoRoute(
    name: 'notification',
    path: '/notification',
    builder: (context, state) => const NotificationPage(),
  ),
  GoRoute(
    name: 'reminder',
    path: '/reminder',
    builder: (context, state) => const ReminderPage(),
  ),
  GoRoute(
    name: 'checkinDetails',
    path: '/checkinDetails',
    builder: (context, state) => const CheckInDetailsPage(),
  ),
  ]
);