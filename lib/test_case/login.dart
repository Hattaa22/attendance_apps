import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fortis_apps/core/data/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AuthService authService = AuthService();

  Future<void> testLogin() async {
    final result = await authService.login('10003', 'password');
    if (result['success']) {
      print('anjay bisa login');
      print('Access token: ${result['data']['access_token']}');
      print('User: ${result['data']['user']}');
    } else {
      print('jir gabisa login: ${result['message']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    testLogin();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Test JWT Login")),
        body: const Center(
          child: Text("Cek terminal"),
        ),
      ),
    );
  }
}
