import 'package:flutter/material.dart';
import 'package:local_service/login_screen.dart';

class UserDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              // Bina puche seedha Login screen pr bhejne k liye
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ), // Aapki Login screen ka naam
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
