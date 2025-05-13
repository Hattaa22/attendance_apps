import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final String _dummyUsername = 'admin';
  final String _dummyPassword = '1234';

  String? _errorMessage;

  void _handleLogin() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username == _dummyUsername && password == _dummyPassword) {
      print("Login");
      setState(() {
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = "Invalid username or password";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Image.asset('assets/logo.png', height: 100), // Ganti sesuai kebutuhan
            ),

            // Sign In Text
            Text(
              'Sign In',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'User Name',
                  hintText: 'Insert User Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Insert Password',
                  prefixIcon: Icon(Icons.key),
                  suffixIcon: Icon(Icons.visibility_off),
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ],

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
              ),
              child: Text("LOGIN", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}