import 'package:flutter/material.dart';

class AppBarCustom extends StatelessWidget {
  const AppBarCustom({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo-fortis.png',
            height: 50,
            fit: BoxFit.cover,
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            iconSize: 30,
            onPressed: () {},
          )
        ],
      ),
    );
  }
}