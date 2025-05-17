import 'package:flutter/material.dart';
import 'package:fortis_apps/view/profile/setting.dart';

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
            height: 37,
            fit: BoxFit.cover,
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            iconSize: 30,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MenuSettingsPage(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}