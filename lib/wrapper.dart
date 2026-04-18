import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_service/home_screen.dart';
import 'package:local_service/login_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Check karein ke stream connect ho rahi hai ya wait kar rahi hai
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFC6FF00), // inDrive theme color
              ),
            ),
          );
        }

        // 2. Agar data mil gaya (User logged in hai)
        if (snapshot.hasData) {
          return HomeScreen();
        }
        // 3. Agar data nahi hai (User logged out hai)
        else {
          return LoginScreen();
        }
      },
    );
  }
}
