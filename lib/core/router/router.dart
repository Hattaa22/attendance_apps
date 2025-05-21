import 'package:fortis_apps/view/auth/login/view/login_screen.dart';
import 'package:fortis_apps/view/splash_screen/splash_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
]);
