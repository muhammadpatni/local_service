import 'package:flutter/material.dart';
import 'phone_login_screen.dart';
import 'google_login_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 40),

            Text(
              "Welcome",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 40),

            ElevatedButton(
              child: Text("Login with Phone"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PhoneLoginScreen()),
                );
              },
            ),

            SizedBox(height: 20),

            ElevatedButton(
              child: Text("Login with Google"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GoogleLoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
