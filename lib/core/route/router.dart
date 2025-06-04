// import 'package:attendance_apps/view/auth/login/view/login_screen.dart';
// import 'package:attendance_apps/view/auth/reset_password/view/reset_password.dart';
import 'package:attendance_apps/view/home/home.dart';
import 'package:attendance_apps/view/splash_screen/splash_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      name: 'splash',
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    // GoRoute(
    //   name: '/login',
    //   path: '/login',
    //   builder: (context, state) => const LoginScreen(),
    // ),
    // GoRoute(
    //   name: '/resetPassword',
    //   path: '/resetPassword',
    //   builder: (context, state) => const ResetPasswordPage(),
    // ),
    GoRoute(
      name: '/home',
      path: '/home',
      builder: (context, state) => const Home(),
    ),
  ]
);