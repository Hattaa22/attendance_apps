import 'package:fortis_apps/view/auth/login/view/login_screen.dart';
import 'package:fortis_apps/view/auth/otp/view/otp.dart';
import 'package:fortis_apps/view/auth/reset_password/view/new_password.dart';
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

final GoRouter router = GoRouter(initialLocation: '/', routes: <RouteBase>[
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
    name: '/changePassword',
    path: '/changePassword',
    builder: (context, state) => const ChangePassword(),
  ),
  GoRoute(
    name: '/newPassword',
    path: '/newPassword',
    builder: (context, state) => NewPasswordPage(
      data: state.extra as Map<String, dynamic>?,
    ),
  ),
  GoRoute(
    name: '/otp',
    path: '/otp',
    builder: (context, state) => OtpPage(
      data: state.extra as Map<String, dynamic>? ?? {}, // ✅ Correct - Map data
    ),
  ),
  GoRoute(
    name: '/home',
    path: '/home',
    builder: (context, state) => const Home(),
  ),
  GoRoute(
    path: '/calendar',
    builder: (context, state) => const CalendarPage(),
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
]);
