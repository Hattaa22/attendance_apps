import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    home: LoginScreen(), 
    debugShowCheckedModeBanner: false
    ),
  );

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String _dummyUsername = 'admin';
  final String _dummyPassword = '1234';

  String? _errorMessage;

  void _handleLogin() {
    if (_usernameController.text == _dummyUsername &&
        _passwordController.text == _dummyPassword) {
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),

          // Logo
          Image.network('https://mir-s3-cdn-cf.behance.net/projects/404/f790db206882689.Y3JvcCwxMzgwLDEwODAsMjcwLDA.png', height: 180), // Tambah asset logomu di sini

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 32, color: Colors.grey[700]),
              SizedBox(width: 10),
              Text(
                "Sign In", 
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold, 
                  color: Colors.black87
                  )
                ),
            ],
          ),

          SizedBox(height: 20),

          Expanded(
            child: Container(
              padding: EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF2E59A7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Username field
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'User Name',
                      hintText: 'Insert User Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Password',
                      hintText: 'Insert Password',
                      prefixIcon: Icon(Icons.key),
                      suffixIcon: Icon(Icons.visibility_off),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[200], fontSize: 14),
                    ),
                  ],

                  SizedBox(height: 56),

                  // Login Button
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "LOGIN",
                      style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
