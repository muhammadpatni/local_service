import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase Initialized Successfully");
  } catch (e) {
    print("❌ Firebase Initialization Failed: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: FirebaseCheckScreen());
  }
}

class FirebaseCheckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Check")),
      body: Center(
        child: Text(
          "If you see this screen, Firebase is initialized ✅",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
