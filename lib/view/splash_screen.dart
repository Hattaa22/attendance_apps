import 'package:attendance_apps/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: SplashScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Color(0xFF2E59A7),
              padding: EdgeInsets.only(top: 264),

                child: Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(top: 2),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Image.network(
                    'https://mir-s3-cdn-cf.behance.net/projects/404/f790db206882689.Y3JvcCwxMzgwLDEwODAsMjcwLDA.png',
                    height: 180,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
